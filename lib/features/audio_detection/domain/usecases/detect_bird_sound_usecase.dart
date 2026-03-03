import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/audio_detection_result.dart';
import '../repositories/audio_detection_repository.dart';

/// Parameters for detecting bird sound
class DetectBirdSoundParams {
  final String audioPath;
  final int numPredictions;
  final double minConfidence;

  const DetectBirdSoundParams({
    required this.audioPath,
    this.numPredictions = 3,
    this.minConfidence = 0.1,
  });
}

/// Usecase for detecting bird sounds
class DetectBirdSoundUsecase {
  final AudioDetectionRepository repository;

  DetectBirdSoundUsecase(this.repository);

  /// Detects bird from audio
  Future<Either<Failure, AudioDetectionResult>> call(
    DetectBirdSoundParams params,
  ) async {
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

    return repository.detectFromAudio(
      params.audioPath,
      numPredictions: params.numPredictions,
      minConfidence: params.minConfidence,
    );
  }

  /// Starts recording
  Future<Either<Failure, void>> startRecording() {
    return repository.startRecording();
  }

  /// Stops recording and returns file path
  Future<Either<Failure, String>> stopRecording() {
    return repository.stopRecording();
  }

  /// Cancels recording
  Future<void> cancelRecording() {
    return repository.cancelRecording();
  }

  /// Gets recording duration stream
  Stream<Duration> get recordingDuration => repository.recordingDuration;

  /// Checks if currently recording
  bool get isRecording => repository.isRecording;
}
