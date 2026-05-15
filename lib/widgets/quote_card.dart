import 'package:flutter/material.dart';

class QuoteCard extends StatelessWidget {
  final String quote;
  final String author;
  final VoidCallback onRefresh;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.author,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.format_quote, color: Colors.indigo, size: 24),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.refresh, color: Colors.indigo, size: 20),
                    onPressed: onRefresh,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              quote,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "- $author",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


