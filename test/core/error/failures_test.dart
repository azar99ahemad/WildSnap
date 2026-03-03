import 'package:flutter_test/flutter_test.dart';
import 'package:wildsnap_pro/core/error/failures.dart';
import 'package:wildsnap_pro/core/error/exceptions.dart';

void main() {
  group('Failures', () {
    test('DetectionFailure should have correct message', () {
      const failure = DetectionFailure(message: 'Detection failed');
      expect(failure.message, 'Detection failed');
    });

    test('CorruptImageFailure should have default message', () {
      const failure = CorruptImageFailure();
      expect(failure.message, 'The image appears to be corrupt or invalid');
      expect(failure.code, 'CORRUPT_IMAGE');
    });

    test('NoDetectionFailure should have default message', () {
      const failure = NoDetectionFailure();
      expect(failure.message, 'No species could be detected in the image');
      expect(failure.code, 'NO_DETECTION');
    });

    test('ModelLoadFailure should have default message', () {
      const failure = ModelLoadFailure();
      expect(failure.message, 'Failed to load the ML model');
      expect(failure.code, 'MODEL_LOAD_ERROR');
    });

    test('NoisyAudioFailure should have default message', () {
      const failure = NoisyAudioFailure();
      expect(failure.message, 'Audio is too noisy to process');
      expect(failure.code, 'NOISY_AUDIO');
    });

    test('StorageFailure should accept custom message', () {
      const failure = StorageFailure(message: 'Storage full');
      expect(failure.message, 'Storage full');
    });

    test('NetworkFailure should have default message', () {
      const failure = NetworkFailure();
      expect(failure.message, 'Network operation failed');
    });

    test('Failure equality should work correctly', () {
      const failure1 = CorruptImageFailure();
      const failure2 = CorruptImageFailure();
      expect(failure1, equals(failure2));
    });
  });

  group('Exceptions', () {
    test('DetectionException should have correct message', () {
      const exception = DetectionException('Test error');
      expect(exception.message, 'Test error');
      expect(exception.toString(), 'DetectionException: Test error');
    });

    test('CorruptImageException should have default message', () {
      const exception = CorruptImageException();
      expect(exception.message, 'Image is corrupt');
    });

    test('ModelLoadException should have default message', () {
      const exception = ModelLoadException();
      expect(exception.message, 'Model failed to load');
    });

    test('AudioException should have default message', () {
      const exception = AudioException();
      expect(exception.message, 'Audio processing failed');
    });

    test('StorageException should have default message', () {
      const exception = StorageException();
      expect(exception.message, 'Storage operation failed');
    });

    test('ServerException should include status code', () {
      const exception = ServerException('Server error', 500);
      expect(exception.statusCode, 500);
      expect(exception.toString(), 'ServerException: Server error (status: 500)');
    });

    test('PermissionException should have default message', () {
      const exception = PermissionException();
      expect(exception.message, 'Permission denied');
    });
  });
}
