import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/audio_utils.dart';
import '../../../detection/data/datasources/model_datasource.dart';
import '../../domain/entities/audio_detection_result.dart';
import '../../domain/entities/detected_bird.dart';
import '../../domain/repositories/audio_detection_repository.dart';
import '../datasources/audio_local_datasource.dart';
import '../models/detected_bird_model.dart';

/// Implementation of AudioDetectionRepository
class AudioDetectionRepositoryImpl implements AudioDetectionRepository {
  final AudioLocalDatasource audioDatasource;
  final ModelDatasource modelDatasource;

  AudioDetectionRepositoryImpl({
    required this.audioDatasource,
    required this.modelDatasource,
  });

  @override
  bool get isModelLoaded => modelDatasource.isAudioModelLoaded;

  @override
  bool get isRecording => audioDatasource.isRecording;

  @override
  Stream<Duration> get recordingDuration => audioDatasource.recordingDuration;

  @override
  Future<Either<Failure, void>> loadModel() async {
    try {
      await modelDatasource.loadAudioModel();
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
  Future<Either<Failure, void>> startRecording() async {
    try {
      await audioDatasource.startRecording();
      return const Right(null);
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } on AudioException catch (e) {
      return Left(AudioFailure(message: e.message));
    } catch (e) {
      return Left(AudioFailure(message: 'Failed to start recording: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> stopRecording() async {
    try {
      final path = await audioDatasource.stopRecording();
      return Right(path);
    } on AudioException catch (e) {
      return Left(AudioFailure(message: e.message));
    } catch (e) {
      return Left(AudioFailure(message: 'Failed to stop recording: $e'));
    }
  }

  @override
  Future<void> cancelRecording() async {
    await audioDatasource.cancelRecording();
  }

  @override
  Future<Either<Failure, AudioDetectionResult>> detectFromAudio(
    String audioPath, {
    int numPredictions = 3,
    double minConfidence = 0.1,
  }) async {
    try {
      final startTime = DateTime.now();

      // Get audio samples
      final samples = await audioDatasource.getAudioSamples(audioPath);

      // Check if audio is too noisy
      if (AudioUtils.isAudioTooNoisy(samples)) {
        return const Left(NoisyAudioFailure());
      }

      // Normalize and convert to spectrogram
      final normalizedSamples = AudioUtils.normalizeAudio(samples);
      final spectrogram = AudioUtils.audioToSpectrogram(normalizedSamples);

      // Run prediction
      final predictions = await modelDatasource.predictFromSpectrogram(
        spectrogram,
        numPredictions: numPredictions,
        minConfidence: minConfidence,
      );

      if (predictions.isEmpty) {
        return const Left(NoDetectionFailure());
      }

      // Convert to entities
      final birds = predictions.map((p) {
        return DetectedBirdModel.fromPrediction(
          label: p.label,
          confidence: p.confidence,
        ).toEntity();
      }).toList();

      final processingTime = DateTime.now().difference(startTime);
      final audioDuration = Duration(
        milliseconds: (samples.length / 16000 * 1000).round(),
      );

      return Right(AudioDetectionResult(
        predictions: birds,
        audioPath: audioPath,
        timestamp: DateTime.now(),
        processingTime: processingTime,
        audioDuration: audioDuration,
      ));
    } on NoisyAudioException {
      return const Left(NoisyAudioFailure());
    } on AudioException catch (e) {
      return Left(AudioFailure(message: e.message));
    } catch (e) {
      return Left(AudioFailure(message: 'Detection failed: $e'));
    }
  }
}
