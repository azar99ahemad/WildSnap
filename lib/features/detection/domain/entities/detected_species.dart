import 'package:equatable/equatable.dart';

/// Entity representing a detected species
class DetectedSpecies extends Equatable {
  final String id;
  final String name;
  final String scientificName;
  final double confidence;
  final String category;
  final String? description;
  final String? habitat;
  final String? imageUrl;
  final Map<String, dynamic>? additionalInfo;

  const DetectedSpecies({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.confidence,
    required this.category,
    this.description,
    this.habitat,
    this.imageUrl,
    this.additionalInfo,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        scientificName,
        confidence,
        category,
        description,
        habitat,
        imageUrl,
        additionalInfo,
      ];

  /// Creates a copy with updated fields
  DetectedSpecies copyWith({
    String? id,
    String? name,
    String? scientificName,
    double? confidence,
    String? category,
    String? description,
    String? habitat,
    String? imageUrl,
    Map<String, dynamic>? additionalInfo,
  }) {
    return DetectedSpecies(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      confidence: confidence ?? this.confidence,
      category: category ?? this.category,
      description: description ?? this.description,
      habitat: habitat ?? this.habitat,
      imageUrl: imageUrl ?? this.imageUrl,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  /// Returns confidence as percentage string
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';
}
