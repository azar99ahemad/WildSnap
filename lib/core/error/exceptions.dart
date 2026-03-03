/// Custom exceptions used throughout the app

/// Exception thrown when detection fails
class DetectionException implements Exception {
  final String message;
  const DetectionException([this.message = 'Detection failed']);

  @override
  String toString() => 'DetectionException: $message';
}

/// Exception thrown when image is corrupt
class CorruptImageException implements Exception {
  final String message;
  const CorruptImageException([this.message = 'Image is corrupt']);

  @override
  String toString() => 'CorruptImageException: $message';
}

/// Exception thrown when no species detected
class NoDetectionException implements Exception {
  final String message;
  const NoDetectionException([this.message = 'No species detected']);

  @override
  String toString() => 'NoDetectionException: $message';
}

/// Exception thrown when ML model fails to load
class ModelLoadException implements Exception {
  final String message;
  const ModelLoadException([this.message = 'Model failed to load']);

  @override
  String toString() => 'ModelLoadException: $message';
}

/// Exception thrown when audio processing fails
class AudioException implements Exception {
  final String message;
  const AudioException([this.message = 'Audio processing failed']);

  @override
  String toString() => 'AudioException: $message';
}

/// Exception thrown when audio is too noisy
class NoisyAudioException implements Exception {
  final String message;
  const NoisyAudioException([this.message = 'Audio is too noisy']);

  @override
  String toString() => 'NoisyAudioException: $message';
}

/// Exception thrown when storage operation fails
class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'Storage operation failed']);

  @override
  String toString() => 'StorageException: $message';
}

/// Exception thrown when cache operation fails
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache operation failed']);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when server responds with error
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException([this.message = 'Server error', this.statusCode]);

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Exception thrown when network is unavailable
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network unavailable']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when permission is denied
class PermissionException implements Exception {
  final String message;
  const PermissionException([this.message = 'Permission denied']);

  @override
  String toString() => 'PermissionException: $message';
}
