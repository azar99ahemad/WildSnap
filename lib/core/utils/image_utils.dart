import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;

/// Utility class for image processing operations
class ImageUtils {
  ImageUtils._();

  /// Compresses image to reduce size before inference
  static Future<Uint8List> compressImage(
    Uint8List imageData, {
    int quality = 85,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    final image = img.decodeImage(imageData);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize if larger than max dimensions
    img.Image resized = image;
    if (image.width > maxWidth || image.height > maxHeight) {
      final ratio = (image.width / image.height);
      int newWidth;
      int newHeight;

      if (ratio > 1) {
        newWidth = maxWidth;
        newHeight = (maxWidth / ratio).round();
      } else {
        newHeight = maxHeight;
        newWidth = (maxHeight * ratio).round();
      }

      resized = img.copyResize(image, width: newWidth, height: newHeight);
    }

    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }

  /// Prepares image for model input (resize to model input size)
  static Future<Uint8List> prepareForModel(
    Uint8List imageData, {
    required int inputSize,
  }) async {
    final image = img.decodeImage(imageData);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final resized = img.copyResize(image, width: inputSize, height: inputSize);
    return Uint8List.fromList(img.encodePng(resized));
  }

  /// Converts image to normalized float array for TFLite input
  static List<List<List<List<double>>>> imageToInputArray(
    Uint8List imageData, {
    required int inputSize,
  }) {
    final image = img.decodeImage(imageData);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final resized = img.copyResize(image, width: inputSize, height: inputSize);

    // Create 4D array [1, height, width, 3]
    final inputArray = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    return inputArray;
  }

  /// Validates if image data is a valid image
  static bool isValidImage(Uint8List imageData) {
    try {
      final image = img.decodeImage(imageData);
      return image != null;
    } catch (_) {
      return false;
    }
  }

  /// Loads image from file path
  static Future<Uint8List> loadImageFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Image file not found: $path');
    }
    return await file.readAsBytes();
  }

  /// Saves image to file
  static Future<String> saveImageToFile(
    Uint8List imageData,
    String directory,
    String filename,
  ) async {
    final dir = Directory(directory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File('$directory/$filename');
    await file.writeAsBytes(imageData);
    return file.path;
  }
}
