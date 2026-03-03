import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/detection_result.dart';

/// Repository interface for species detection
abstract class DetectionRepository {
  /// Detects species from image data
  /// Returns [DetectionResult] on success or [Failure] on error
  Future<Either<Failure, DetectionResult>> detectFromImage(
    Uint8List imageData, {
    int numPredictions = 3,
    double minConfidence = 0.1,
  });

  /// Detects species from image file path
  Future<Either<Failure, DetectionResult>> detectFromFile(
    String imagePath, {
    int numPredictions = 3,
    double minConfidence = 0.1,
  });

  /// Loads the ML model
  Future<Either<Failure, void>> loadModel();

  /// Disposes the ML model
  Future<void> disposeModel();

  /// Checks if model is loaded
  bool get isModelLoaded;
}
