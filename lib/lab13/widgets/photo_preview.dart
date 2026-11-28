
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPreview extends StatelessWidget {
  final XFile? photo;
  final VoidCallback onTap;

  const PhotoPreview({
    super.key,
    required this.photo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(23),
      child: Container(
        width: double.infinity,
        height: 245,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFE9E5DB),
          borderRadius: BorderRadius.circular(23),
        ),
        child: photo == null
            ? const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 52,
              color: Color(0xFF718776),
            ),
            SizedBox(height: 16),
            Text(
              'A new memory starts here',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 21,
                color: Color(0xFF354D40),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap to add your favorite moment',
              style: TextStyle(
                color: Colors.black45,
              ),
            ),
          ],
        )
            : Image.file(
          File(photo!.path),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
          const Center(
            child: Icon(
              Icons.broken_image_outlined,
            ),
          ),
        ),
      ),
    );
  }
}
