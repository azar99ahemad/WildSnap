import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dartz/dartz.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';

import '../../../core/error/failures.dart';

/// Service for sharing detection results
abstract class ShareService {
  /// Shares text content
  Future<Either<Failure, void>> shareText(String text);

  /// Shares image with text
  Future<Either<Failure, void>> shareImage(
    Uint8List imageData,
    String text, {
    String? subject,
  });

  /// Captures widget as image
  Future<Either<Failure, Uint8List>> captureWidget(
    ScreenshotController controller,
  );

  /// Shares result card as image
  Future<Either<Failure, void>> shareResultCard({
    required String speciesName,
    required String confidence,
    required Uint8List? imageData,
    required ScreenshotController controller,
  });
}

/// Implementation of ShareService
class ShareServiceImpl implements ShareService {
  @override
  Future<Either<Failure, void>> shareText(String text) async {
    try {
      await Share.share(text);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to share: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> shareImage(
    Uint8List imageData,
    String text, {
    String? subject,
  }) async {
    try {
      // Save image to temp file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/share_image_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageData);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: text,
        subject: subject,
      );

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to share image: $e'));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> captureWidget(
    ScreenshotController controller,
  ) async {
    try {
      final image = await controller.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 2.0,
      );

      if (image == null) {
        return const Left(UnknownFailure(message: 'Failed to capture widget'));
      }

      return Right(image);
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to capture: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> shareResultCard({
    required String speciesName,
    required String confidence,
    required Uint8List? imageData,
    required ScreenshotController controller,
  }) async {
    try {
      // Capture the result card
      final captureResult = await captureWidget(controller);

      return captureResult.fold(
        (failure) => Left(failure),
        (cardImage) async {
          final text = 'I detected $speciesName with $confidence confidence '
              'using WildSnap Pro! 🦁🐦\n\n#WildSnapPro #Wildlife #Nature';

          return shareImage(cardImage, text, subject: 'Wildlife Detection');
        },
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to share result: $e'));
    }
  }
}
