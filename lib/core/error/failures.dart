import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure when detecting species from image
class DetectionFailure extends Failure {
  const DetectionFailure({required super.message, super.code});
}

/// Failure when image is corrupt or invalid
class CorruptImageFailure extends Failure {
  const CorruptImageFailure({
    super.message = 'The image appears to be corrupt or invalid',
    super.code = 'CORRUPT_IMAGE',
  });
}

/// Failure when no species detected
class NoDetectionFailure extends Failure {
  const NoDetectionFailure({
    super.message = 'No species could be detected in the image',
    super.code = 'NO_DETECTION',
  });
}

/// Failure when ML model fails to load
class ModelLoadFailure extends Failure {
  const ModelLoadFailure({
    super.message = 'Failed to load the ML model',
    super.code = 'MODEL_LOAD_ERROR',
  });
}

/// Failure related to audio processing
class AudioFailure extends Failure {
  const AudioFailure({required super.message, super.code});
}

/// Failure when audio is too noisy
class NoisyAudioFailure extends Failure {
  const NoisyAudioFailure({
    super.message = 'Audio is too noisy to process',
    super.code = 'NOISY_AUDIO',
  });
}

/// Failure when audio recording fails
class AudioRecordingFailure extends Failure {
  const AudioRecordingFailure({
    super.message = 'Failed to record audio',
    super.code = 'AUDIO_RECORDING_ERROR',
  });
}

/// Failure related to storage operations
class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});
}

/// Failure when storage is full
class StorageFullFailure extends Failure {
  const StorageFullFailure({
    super.message = 'Device storage is full',
    super.code = 'STORAGE_FULL',
  });
}

/// Failure related to permissions
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}

/// Failure related to network operations
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network operation failed',
    super.code,
  });
}

/// Failure when server returns error
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred',
    super.code,
  });
}

/// Cache-related failure
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache operation failed',
    super.code,
  });
}

/// Unknown/unexpected failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred',
    super.code = 'UNKNOWN_ERROR',
  });
}
