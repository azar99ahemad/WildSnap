import 'package:equatable/equatable.dart';
import 'detected_bird.dart';

/// Entity representing audio detection result
class AudioDetectionResult extends Equatable {
  final List<DetectedBird> predictions;
  final String audioPath;
  final DateTime timestamp;
  final Duration processingTime;
  final Duration audioDuration;

  const AudioDetectionResult({
    required this.predictions,
    required this.audioPath,
    required this.timestamp,
    required this.processingTime,
    required this.audioDuration,
  });

  @override
  List<Object?> get props => [
        predictions,
        audioPath,
        timestamp,
        processingTime,
        audioDuration,
      ];

  /// Returns the top prediction
  DetectedBird? get topPrediction =>
      predictions.isNotEmpty ? predictions.first : null;

  /// Checks if any valid detection was made
  bool get hasDetection => predictions.isNotEmpty;

  /// Returns predictions sorted by confidence
  List<DetectedBird> get sortedPredictions {
    final sorted = List<DetectedBird>.from(predictions);
    sorted.sort((a, b) => b.confidence.compareTo(a.confidence));
    return sorted;
  }
}
