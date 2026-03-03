import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/image_utils.dart';
import '../../domain/entities/detected_species.dart';
import '../../domain/entities/detection_result.dart';
import '../../domain/repositories/detection_repository.dart';
import '../datasources/detection_local_datasource.dart';
import '../datasources/model_datasource.dart';
import '../models/detected_species_model.dart';

/// Implementation of DetectionRepository
class DetectionRepositoryImpl implements DetectionRepository {
  final ModelDatasource modelDatasource;
  final DetectionLocalDatasource localDatasource;

  DetectionRepositoryImpl({
    required this.modelDatasource,
    required this.localDatasource,
  });

  @override
  bool get isModelLoaded => modelDatasource.isImageModelLoaded;

  @override
  Future<Either<Failure, void>> loadModel() async {
    try {
      await modelDatasource.loadImageModel();
      return const Right(null);
    } on ModelLoadException catch (e) {
      return Left(ModelLoadFailure(message: e.message));
    } catch (e) {
      return Left(ModelLoadFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<void> disposeModel() async {
    await modelDatasource.dispose();
  }

  @override
  Future<Either<Failure, DetectionResult>> detectFromImage(
    Uint8List imageData, {
    int numPredictions = 3,
    double minConfidence = 0.1,
  }) async {
    try {
      final startTime = DateTime.now();

      // Validate image
      if (!ImageUtils.isValidImage(imageData)) {
        return const Left(CorruptImageFailure());
      }

      // Compress image for better performance
      final compressedImage = await ImageUtils.compressImage(imageData);

      // Run prediction
      final predictions = await modelDatasource.predictFromImage(
        compressedImage,
        numPredictions: numPredictions,
        minConfidence: minConfidence,
      );

      if (predictions.isEmpty) {
        return const Left(NoDetectionFailure());
      }

      // Convert predictions to entities
      final species = await Future.wait(
        predictions.map((p) async {
          final speciesInfo = await localDatasource.getSpeciesInfo(p.label);
          return DetectedSpeciesModel.fromPrediction(
            label: p.label,
            confidence: p.confidence,
            speciesInfo: speciesInfo.isNotEmpty ? speciesInfo : null,
          ).toEntity();
        }),
      );

      final processingTime = DateTime.now().difference(startTime);

      return Right(DetectionResult(
        predictions: species,
        imagePath: '', // Will be set when saved
        timestamp: DateTime.now(),
        processingTime: processingTime,
      ));
    } on CorruptImageException {
      return const Left(CorruptImageFailure());
    } on DetectionException catch (e) {
      return Left(DetectionFailure(message: e.message));
    } catch (e) {
      return Left(DetectionFailure(message: 'Detection failed: $e'));
    }
  }

  @override
  Future<Either<Failure, DetectionResult>> detectFromFile(
    String imagePath, {
    int numPredictions = 3,
    double minConfidence = 0.1,
  }) async {
    try {
      final imageData = await ImageUtils.loadImageFromFile(imagePath);
      final result = await detectFromImage(
        imageData,
        numPredictions: numPredictions,
        minConfidence: minConfidence,
      );

      return result.map((detection) => detection.copyWith(imagePath: imagePath));
    } catch (e) {
      return Left(DetectionFailure(message: 'Failed to load image: $e'));
    }
  }
}
