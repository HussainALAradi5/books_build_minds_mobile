import 'package:flutter/material.dart';

import '../../app/library_theme.dart';
import '../../shared/network/api_client.dart';
import '../../models/catalog/book.dart';

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.book,
    required this.api,
    this.height = 210,
  });

  final Book book;
  final ApiClient api;
  final double height;

  @override
  Widget build(BuildContext context) {
    final image = book.imagePath;
    final palette = [
      const Color(0xFF25483F),
      const Color(0xFF945B52),
      const Color(0xFF47596C),
      const Color(0xFF75624B),
    ];
    final color = palette[book.bookId.abs() % palette.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: image != null && image.isNotEmpty
            ? Image.network(
                api.assetUri(image).toString(),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(color),
              )
            : _fallback(color),
      ),
    );
  }

  Widget _fallback(Color color) => Container(
    padding: EdgeInsets.all(height < 200 ? 12 : 18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [color, Color.lerp(color, Colors.black, .24)!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: height <= 130
        ? Center(
            child: Text(
              book.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: LibraryTheme.cream,
              ),
            ),
          )
        : Column(
            children: [
              const Text(
                'BOOKS BUILD MINDS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  letterSpacing: 1.7,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                book.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: height < 200 ? 20 : 25,
                  fontWeight: FontWeight.w600,
                  color: LibraryTheme.cream,
                ),
              ),
              SizedBox(height: height < 200 ? 5 : 12),
              Text(
                book.author.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  letterSpacing: 1.2,
                  fontSize: 10,
                ),
              ),
              if (height >= 200) ...[
                const Spacer(),
                const Icon(
                  Icons.auto_stories_outlined,
                  color: Colors.white54,
                  size: 28,
                ),
              ],
            ],
          ),
  );
}
