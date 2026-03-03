import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/detection_provider.dart';
import '../widgets/detection_result_card.dart';
import '../widgets/image_preview_widget.dart';
import '../widgets/skeleton_loader.dart';

/// Main page for image-based species detection
class ImageDetectionPage extends ConsumerStatefulWidget {
  const ImageDetectionPage({super.key});

  @override
  ConsumerState<ImageDetectionPage> createState() => _ImageDetectionPageState();
}

class _ImageDetectionPageState extends ConsumerState<ImageDetectionPage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageData;
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    final detectionState = ref.watch(detectionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detect Species'),
        centerTitle: true,
        actions: [
          if (_imageData != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetDetection,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image preview or placeholder
              _buildImageSection(),
              const SizedBox(height: 24),

              // Action buttons
              if (_imageData == null) _buildImageSourceButtons(),

              // Detection result or loading state
              _buildDetectionResult(detectionState),
            ],
          ),
        ),
      ),
      floatingActionButton: _imageData != null &&
              detectionState is! DetectionLoading &&
              detectionState is! DetectionSuccess
          ? FloatingActionButton.extended(
              onPressed: _startDetection,
              icon: const Icon(Icons.search),
              label: const Text('Detect'),
            )
          : null,
    );
  }

  Widget _buildImageSection() {
    if (_imageData == null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Select an image to detect species',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ImagePreviewWidget(
      imageData: _imageData!,
      onRemove: _resetDetection,
    );
  }

  Widget _buildImageSourceButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetectionResult(DetectionState state) {
    return switch (state) {
      DetectionInitial() => const SizedBox.shrink(),
      DetectionLoading() => const Padding(
          padding: EdgeInsets.only(top: 24),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyzing image...'),
            ],
          ),
        ),
      DetectionSuccess(result: final result) => Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Detection Results',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...result.predictions.map(
                (species) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DetectionResultCard(
                    species: species,
                    imagePath: _imagePath,
                  ),
                ),
              ),
              if (result.predictions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No species detected in the image'),
                  ),
                ),
            ],
          ),
        ),
      DetectionError(message: final message) => Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    };
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageData = bytes;
          _imagePath = image.path;
        });
        ref.read(selectedImageProvider.notifier).state = bytes;
        ref.read(selectedImagePathProvider.notifier).state = image.path;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _startDetection() {
    if (_imageData != null) {
      ref.read(detectionNotifierProvider.notifier).detectFromImage(_imageData!);
    }
  }

  void _resetDetection() {
    setState(() {
      _imageData = null;
      _imagePath = null;
    });
    ref.read(selectedImageProvider.notifier).state = null;
    ref.read(selectedImagePathProvider.notifier).state = null;
    ref.read(detectionNotifierProvider.notifier).reset();
  }
}
