import 'package:equatable/equatable.dart';

/// Entity representing a detected bird from audio
class DetectedBird extends Equatable {
  final String id;
  final String name;
  final String scientificName;
  final double confidence;
  final String? description;
  final String? habitat;
  final String? audioSample;
  final String? imageUrl;
  final Map<String, dynamic>? additionalInfo;

  const DetectedBird({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.confidence,
    this.description,
    this.habitat,
    this.audioSample,
    this.imageUrl,
    this.additionalInfo,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        scientificName,
        confidence,
        description,
        habitat,
        audioSample,
        imageUrl,
        additionalInfo,
      ];

  /// Returns confidence as percentage string
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  /// Creates a copy with updated fields
  DetectedBird copyWith({
    String? id,
    String? name,
    String? scientificName,
    double? confidence,
    String? description,
    String? habitat,
    String? audioSample,
    String? imageUrl,
    Map<String, dynamic>? additionalInfo,
  }) {
    return DetectedBird(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      confidence: confidence ?? this.confidence,
      description: description ?? this.description,
      habitat: habitat ?? this.habitat,
      audioSample: audioSample ?? this.audioSample,
      imageUrl: imageUrl ?? this.imageUrl,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
