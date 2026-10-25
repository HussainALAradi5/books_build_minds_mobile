import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../interfaces/network/upload_file.dart';

class ImagePickerButton extends StatefulWidget {
  const ImagePickerButton({
    super.key,
    required this.label,
    required this.onPicked,
    this.multiple = false,
  });

  final String label;
  final bool multiple;
  final Future<void> Function(List<UploadFile>) onPicked;

  @override
  State<ImagePickerButton> createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  bool busy = false;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: busy ? null : _pick,
    icon: busy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.add_photo_alternate_outlined),
    label: Text(widget.label),
  );

  Future<void> _pick() async {
    setState(() => busy = true);
    try {
      final result = widget.multiple
          ? await FilePicker.pickFiles(type: FileType.image)
          : [?await FilePicker.pickFile(type: FileType.image)];
      if (result.isEmpty) return;
      if (result.length > 10) {
        throw StateError('Choose no more than 10 images.');
      }
      final files = <UploadFile>[];
      for (final item in result) {
        if ((item.lengthSync() ?? 0) > 5 * 1024 * 1024) {
          throw StateError('Each image must be 5 MB or smaller.');
        }
        final bytes = await item.readAsBytes();
        if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
          throw StateError('Each image must be between 1 byte and 5 MB.');
        }
        final extension = item.extension?.toLowerCase();
        final mime = switch (extension) {
          'jpg' || 'jpeg' => 'image/jpeg',
          'png' => 'image/png',
          'gif' => 'image/gif',
          'webp' => 'image/webp',
          _ => throw StateError('Choose a JPEG, PNG, GIF, or WebP image.'),
        };
        files.add(UploadFile(name: item.name, mimeType: mime, bytes: bytes));
      }
      await widget.onPicked(files);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
