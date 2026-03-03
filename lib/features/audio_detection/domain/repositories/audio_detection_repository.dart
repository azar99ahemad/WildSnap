import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/audio_detection_result.dart';

/// Repository interface for audio detection
abstract class AudioDetectionRepository {
  /// Detects bird from audio file
  Future<Either<Failure, AudioDetectionResult>> detectFromAudio(
    String audioPath, {
    int numPredictions = 3,
    double minConfidence = 0.1,
  });

  /// Starts audio recording
  Future<Either<Failure, void>> startRecording();

  /// Stops audio recording and returns file path
  Future<Either<Failure, String>> stopRecording();

  /// Cancels recording
  Future<void> cancelRecording();

  /// Loads the audio ML model
  Future<Either<Failure, void>> loadModel();

  /// Disposes the ML model
  Future<void> disposeModel();

  /// Checks if model is loaded
  bool get isModelLoaded;

  /// Checks if currently recording
  bool get isRecording;

  /// Returns recording duration stream
  Stream<Duration> get recordingDuration;
}
