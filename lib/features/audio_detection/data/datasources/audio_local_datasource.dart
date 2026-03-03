import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/audio_utils.dart';

/// Local data source for audio operations
abstract class AudioLocalDatasource {
  /// Starts audio recording
  Future<void> startRecording();

  /// Stops recording and returns file path
  Future<String> stopRecording();

  /// Cancels recording
  Future<void> cancelRecording();

  /// Gets audio samples from file
  Future<List<double>> getAudioSamples(String filePath);

  /// Checks if currently recording
  bool get isRecording;

  /// Recording duration stream
  Stream<Duration> get recordingDuration;

  /// Disposes recorder
  Future<void> dispose();
}

/// Implementation of AudioLocalDatasource using flutter_sound
class AudioLocalDatasourceImpl implements AudioLocalDatasource {
  FlutterSoundRecorder? _recorder;
  String? _currentRecordingPath;
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  Timer? _durationTimer;
  DateTime? _recordingStartTime;
  final Uuid _uuid = const Uuid();

  @override
  bool get isRecording => _recorder?.isRecording ?? false;

  @override
  Stream<Duration> get recordingDuration => _durationController.stream;

  Future<void> _initRecorder() async {
    if (_recorder != null) return;

    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    await _recorder!.setSubscriptionDuration(
      const Duration(milliseconds: 100),
    );
  }

  @override
  Future<void> startRecording() async {
    try {
      // Check permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        throw const PermissionException('Microphone permission denied');
      }

      await _initRecorder();

      // Generate file path
      final directory = await getTemporaryDirectory();
      _currentRecordingPath = '${directory.path}/recording_${_uuid.v4()}.wav';

      // Start recording
      await _recorder!.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.pcm16WAV,
        sampleRate: AppConstants.audioSampleRate,
        numChannels: 1,
      );

      // Start duration timer
      _recordingStartTime = DateTime.now();
      _durationTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) {
          if (_recordingStartTime != null) {
            final duration = DateTime.now().difference(_recordingStartTime!);
            _durationController.add(duration);

            // Auto-stop at max duration
            if (duration.inSeconds >= AppConstants.maxRecordingDurationSeconds) {
              stopRecording();
            }
          }
        },
      );
    } catch (e) {
      if (e is PermissionException) rethrow;
      throw AudioException('Failed to start recording: $e');
    }
  }

  @override
  Future<String> stopRecording() async {
    try {
      _durationTimer?.cancel();
      _durationTimer = null;
      _recordingStartTime = null;

      if (_recorder == null || !_recorder!.isRecording) {
        throw const AudioException('No active recording');
      }

      await _recorder!.stopRecorder();

      final path = _currentRecordingPath;
      if (path == null) {
        throw const AudioException('Recording path not found');
      }

      _currentRecordingPath = null;
      return path;
    } catch (e) {
      if (e is AudioException) rethrow;
      throw AudioException('Failed to stop recording: $e');
    }
  }

  @override
  Future<void> cancelRecording() async {
    _durationTimer?.cancel();
    _durationTimer = null;
    _recordingStartTime = null;

    if (_recorder?.isRecording ?? false) {
      await _recorder!.stopRecorder();
    }

    // Delete the recording file if exists
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    _currentRecordingPath = null;
  }

  @override
  Future<List<double>> getAudioSamples(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw const AudioException('Audio file not found');
      }

      final bytes = await file.readAsBytes();
      
      // Skip WAV header (44 bytes) and convert to samples
      final audioBytes = bytes.sublist(44);
      return AudioUtils.bytesToSamples(audioBytes);
    } catch (e) {
      if (e is AudioException) rethrow;
      throw AudioException('Failed to read audio file: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _durationTimer?.cancel();
    await _recorder?.closeRecorder();
    _recorder = null;
    await _durationController.close();
  }
}
