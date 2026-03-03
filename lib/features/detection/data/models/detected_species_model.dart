import 'package:equatable/equatable.dart';
import '../../domain/entities/detected_species.dart';

/// Data model for detected species
class DetectedSpeciesModel extends Equatable {
  final String id;
  final String name;
  final String scientificName;
  final double confidence;
  final String category;
  final String? description;
  final String? habitat;
  final String? imageUrl;
  final Map<String, dynamic>? additionalInfo;

  const DetectedSpeciesModel({
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

  /// Creates model from JSON
  factory DetectedSpeciesModel.fromJson(Map<String, dynamic> json) {
    return DetectedSpeciesModel(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientific_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String?,
      habitat: json['habitat'] as String?,
      imageUrl: json['image_url'] as String?,
      additionalInfo: json['additional_info'] as Map<String, dynamic>?,
    );
  }

  /// Converts model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'confidence': confidence,
      'category': category,
      'description': description,
      'habitat': habitat,
      'image_url': imageUrl,
      'additional_info': additionalInfo,
    };
  }

  /// Converts model to domain entity
  DetectedSpecies toEntity() {
    return DetectedSpecies(
      id: id,
      name: name,
      scientificName: scientificName,
      confidence: confidence,
      category: category,
      description: description,
      habitat: habitat,
      imageUrl: imageUrl,
      additionalInfo: additionalInfo,
    );
  }

  /// Creates model from domain entity
  factory DetectedSpeciesModel.fromEntity(DetectedSpecies entity) {
    return DetectedSpeciesModel(
      id: entity.id,
      name: entity.name,
      scientificName: entity.scientificName,
      confidence: entity.confidence,
      category: entity.category,
      description: entity.description,
      habitat: entity.habitat,
      imageUrl: entity.imageUrl,
      additionalInfo: entity.additionalInfo,
    );
  }

  /// Creates model from prediction result
  factory DetectedSpeciesModel.fromPrediction({
    required String label,
    required double confidence,
    Map<String, dynamic>? speciesInfo,
  }) {
    final info = speciesInfo ?? {};
    return DetectedSpeciesModel(
      id: info['id'] as String? ?? label.toLowerCase().replaceAll(' ', '_'),
      name: info['name'] as String? ?? label,
      scientificName: info['scientific_name'] as String? ?? '',
      confidence: confidence,
      category: info['category'] as String? ?? 'unknown',
      description: info['description'] as String?,
      habitat: info['habitat'] as String?,
      imageUrl: info['image_url'] as String?,
      additionalInfo: info['additional_info'] as Map<String, dynamic>?,
    );
  }
}
