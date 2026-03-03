import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/detection_result.dart';
import '../repositories/detection_repository.dart';

/// Parameters for detect species usecase
class DetectSpeciesParams {
  final Uint8List? imageData;
  final String? imagePath;
  final int numPredictions;
  final double minConfidence;

  const DetectSpeciesParams({
    this.imageData,
    this.imagePath,
    this.numPredictions = 3,
    this.minConfidence = 0.1,
  }) : assert(imageData != null || imagePath != null,
            'Either imageData or imagePath must be provided');
}

/// Usecase for detecting species from images
class DetectSpeciesUsecase {
  final DetectionRepository repository;

  DetectSpeciesUsecase(this.repository);

  /// Executes the species detection
  Future<Either<Failure, DetectionResult>> call(DetectSpeciesParams params) async {
    // Ensure model is loaded
    if (!repository.isModelLoaded) {
      final loadResult = await repository.loadModel();
      if (loadResult.isLeft()) {
        return Left(loadResult.fold(
          (failure) => failure,
          (_) => const ModelLoadFailure(),
        ));
      }
    }

    // Perform detection
    if (params.imageData != null) {
      return repository.detectFromImage(
        params.imageData!,
        numPredictions: params.numPredictions,
        minConfidence: params.minConfidence,
      );
    } else {
      return repository.detectFromFile(
        params.imagePath!,
        numPredictions: params.numPredictions,
        minConfidence: params.minConfidence,
      );
    }
  }
}
