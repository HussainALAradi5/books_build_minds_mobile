import 'package:flutter/material.dart';

import '../../models/media/media_item.dart';
import '../../models/shared/page_result.dart';
import '../../services/media/media_service.dart';
import '../../shared/network/api_client.dart';

class BookMediaGallery extends StatefulWidget {
  const BookMediaGallery({
    super.key,
    required this.bookId,
    required this.media,
    required this.api,
  });
  final int bookId;
  final MediaService media;
  final ApiClient api;

  @override
  State<BookMediaGallery> createState() => _BookMediaGalleryState();
}

class _BookMediaGalleryState extends State<BookMediaGallery> {
  late Future<PageResult<MediaItem>> images;

  @override
  void initState() {
    super.initState();
    images = widget.media.list(widget.bookId, 1);
  }

  @override
  void didUpdateWidget(covariant BookMediaGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      images = widget.media.list(widget.bookId, 1);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<PageResult<MediaItem>>(
    future: images,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return TextButton.icon(
          onPressed: () =>
              setState(() => images = widget.media.list(widget.bookId, 1)),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry book images'),
        );
      }
      if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Book images', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final image = snapshot.data!.items[index];
                final url = widget.api.assetUri(image.url).toString();
                return InkWell(
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (dialog) => Dialog(
                      child: Stack(
                        children: [
                          InteractiveViewer(
                            minScale: 1,
                            maxScale: 5,
                            child: Image.network(url, fit: BoxFit.contain),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: IconButton.filledTonal(
                              onPressed: () => Navigator.pop(dialog),
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      width: 90,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
