import 'dart:io';

import 'package:flutter/material.dart';

class ScannedImagePreview extends StatelessWidget {
  const ScannedImagePreview({
    super.key,
    required this.imagePath,
    this.aspectRatio = 16 / 10,
  });

  final String imagePath;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: Colors.black12,
            child: Center(child: Icon(Icons.broken_image_outlined)),
          ),
        ),
      ),
    );
  }
}
