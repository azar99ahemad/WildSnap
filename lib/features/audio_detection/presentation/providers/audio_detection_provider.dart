import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/audio_detection_result.dart';
import '../../domain/usecases/detect_bird_sound_usecase.dart';

/// State for audio detection feature
sealed class AudioDetectionState {
  const AudioDetectionState();
}

class AudioDetectionInitial extends AudioDetectionState {
  const AudioDetectionInitial();
}

class AudioRecording extends AudioDetectionState {
  final Duration duration;
  const AudioRecording(this.duration);
}

class AudioDetectionLoading extends AudioDetectionState {
  const AudioDetectionLoading();
}

class AudioDetectionSuccess extends AudioDetectionState {
  final AudioDetectionResult result;
  const AudioDetectionSuccess(this.result);
}

class AudioDetectionError extends AudioDetectionState {
  final String message;
  const AudioDetectionError(this.message);
}

/// Notifier for audio detection state
class AudioDetectionNotifier extends StateNotifier<AudioDetectionState> {
  final DetectBirdSoundUsecase _detectBirdSoundUsecase;
  StreamSubscription<Duration>? _durationSubscription;
  String? _recordedAudioPath;

  AudioDetectionNotifier(this._detectBirdSoundUsecase)
      : super(const AudioDetectionInitial());

  /// Starts recording audio
  Future<void> startRecording() async {
    final result = await _detectBirdSoundUsecase.startRecording();

    result.fold(
      (failure) => state = AudioDetectionError(failure.message),
      (_) {
        // Listen to duration updates
        _durationSubscription =
            _detectBirdSoundUsecase.recordingDuration.listen((duration) {
          state = AudioRecording(duration);
        });
      },
    );
  }

  /// Stops recording and starts detection
  Future<void> stopRecordingAndDetect() async {
    _durationSubscription?.cancel();
    _durationSubscription = null;

    state = const AudioDetectionLoading();

    final stopResult = await _detectBirdSoundUsecase.stopRecording();

    await stopResult.fold(
      (failure) async {
        state = AudioDetectionError(failure.message);
      },
      (audioPath) async {
        _recordedAudioPath = audioPath;

        // Run detection
        final detectResult = await _detectBirdSoundUsecase(
          DetectBirdSoundParams(audioPath: audioPath),
        );

        detectResult.fold(
          (failure) => state = AudioDetectionError(failure.message),
          (result) => state = AudioDetectionSuccess(result),
        );
      },
    );
  }

  /// Cancels recording
  Future<void> cancelRecording() async {
    _durationSubscription?.cancel();
    _durationSubscription = null;
    await _detectBirdSoundUsecase.cancelRecording();
    state = const AudioDetectionInitial();
  }

  /// Resets state
  void reset() {
    _durationSubscription?.cancel();
    _durationSubscription = null;
    _recordedAudioPath = null;
    state = const AudioDetectionInitial();
  }

  /// Gets the recorded audio path
  String? get recordedAudioPath => _recordedAudioPath;

  @override
  void dispose() {
    _durationSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for audio detection notifier
final audioDetectionNotifierProvider =
    StateNotifierProvider<AudioDetectionNotifier, AudioDetectionState>((ref) {
  return AudioDetectionNotifier(sl<DetectBirdSoundUsecase>());
});
