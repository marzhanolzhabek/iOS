
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/diary_entry.dart';

class DiaryEntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  const DiaryEntryCard({
    super.key,
    required this.entry,
    required this.onFavorite,
    required this.onDelete,
  });

  String _date(DateTime d) {
    String pad(int n) =>
        n.toString().padLeft(2, '0');

    return '${d.year}-${pad(d.month)}-${pad(d.day)} '
        '${pad(d.hour)}:${pad(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Image.file(
                File(entry.imagePath),
                height: 185,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                const SizedBox(
                  height: 185,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    tooltip: 'Favorite',
                    onPressed: onFavorite,
                    icon: Icon(
                      entry.favorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: entry.favorite
                          ? Colors.red
                          : const Color(0xFF354D40),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  entry.caption,
                  style: const TextStyle(
                    fontSize: 22,
                    fontFamily: 'serif',
                    color: Color(0xFF354D40),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '📍 ${entry.latitude.toStringAsFixed(5)}, '
                      '${entry.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '🕒 ${_date(entry.timestamp)}',
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Altitude '
                            '${entry.altitude.toStringAsFixed(1)} m'
                            '  •  ±${entry.accuracy.toStringAsFixed(1)} m',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete entry',
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
