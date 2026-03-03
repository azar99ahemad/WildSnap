import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Widget to preview selected image
class ImagePreviewWidget extends StatelessWidget {
  final Uint8List imageData;
  final VoidCallback? onRemove;
  final double? height;
  final BorderRadius? borderRadius;

  const ImagePreviewWidget({
    super.key,
    required this.imageData,
    this.onRemove,
    this.height = 300,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: Image.memory(
            imageData,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: height,
              color: Theme.of(context).colorScheme.errorContainer,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onRemove,
                tooltip: 'Remove image',
              ),
            ),
          ),
      ],
    );
  }
}
