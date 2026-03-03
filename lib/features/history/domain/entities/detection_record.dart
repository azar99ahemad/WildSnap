import 'package:equatable/equatable.dart';

/// Enum for detection type
enum DetectionType {
  image,
  audio,
}

/// Entity representing a detection history record
class DetectionRecord extends Equatable {
  final String id;
  final String speciesName;
  final String scientificName;
  final double confidence;
  final DetectionType detectionType;
  final String? imagePath;
  final String? audioPath;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;

  const DetectionRecord({
    required this.id,
    required this.speciesName,
    required this.scientificName,
    required this.confidence,
    required this.detectionType,
    this.imagePath,
    this.audioPath,
    required this.timestamp,
    this.additionalData,
  });

  @override
  List<Object?> get props => [
        id,
        speciesName,
        scientificName,
        confidence,
        detectionType,
        imagePath,
        audioPath,
        timestamp,
        additionalData,
      ];

  /// Creates a copy with updated fields
  DetectionRecord copyWith({
    String? id,
    String? speciesName,
    String? scientificName,
    double? confidence,
    DetectionType? detectionType,
    String? imagePath,
    String? audioPath,
    DateTime? timestamp,
    Map<String, dynamic>? additionalData,
  }) {
    return DetectionRecord(
      id: id ?? this.id,
      speciesName: speciesName ?? this.speciesName,
      scientificName: scientificName ?? this.scientificName,
      confidence: confidence ?? this.confidence,
      detectionType: detectionType ?? this.detectionType,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      timestamp: timestamp ?? this.timestamp,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  /// Returns confidence as percentage string
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';
}
