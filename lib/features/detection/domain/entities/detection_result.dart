import 'package:equatable/equatable.dart';
import 'detected_species.dart';

/// Entity representing detection result with multiple predictions
class DetectionResult extends Equatable {
  final List<DetectedSpecies> predictions;
  final String imagePath;
  final DateTime timestamp;
  final Duration processingTime;

  const DetectionResult({
    required this.predictions,
    required this.imagePath,
    required this.timestamp,
    required this.processingTime,
  });

  @override
  List<Object?> get props => [predictions, imagePath, timestamp, processingTime];

  /// Returns the top prediction (highest confidence)
  DetectedSpecies? get topPrediction =>
      predictions.isNotEmpty ? predictions.first : null;

  /// Checks if any valid detection was made
  bool get hasDetection => predictions.isNotEmpty;

  /// Returns predictions sorted by confidence
  List<DetectedSpecies> get sortedPredictions {
    final sorted = List<DetectedSpecies>.from(predictions);
    sorted.sort((a, b) => b.confidence.compareTo(a.confidence));
    return sorted;
  }

  /// Creates a copy with updated fields
  DetectionResult copyWith({
    List<DetectedSpecies>? predictions,
    String? imagePath,
    DateTime? timestamp,
    Duration? processingTime,
  }) {
    return DetectionResult(
      predictions: predictions ?? this.predictions,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
      processingTime: processingTime ?? this.processingTime,
    );
  }
}
