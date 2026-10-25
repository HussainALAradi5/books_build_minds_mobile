import 'package:flutter/material.dart';

import 'modal_heading.dart';

class ResponsiveFormDialog extends StatelessWidget {
  const ResponsiveFormDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.busy = false,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final close = busy ? null : () => Navigator.pop(context);
    if (MediaQuery.sizeOf(context).width >= 600) {
      return AlertDialog(
        insetPadding: const EdgeInsets.all(24),
        title: ModalHeading(title: title, onClose: close, canClose: !busy),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .72,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
            child: content,
          ),
        ),
        actions: actions,
      );
    }
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            tooltip: 'Close $title',
            onPressed: close,
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: content,
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          ),
        ),
      ),
    );
  }
}
