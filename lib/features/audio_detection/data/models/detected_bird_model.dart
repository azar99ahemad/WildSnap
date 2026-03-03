import 'package:equatable/equatable.dart';
import '../../domain/entities/detected_bird.dart';

/// Data model for detected bird
class DetectedBirdModel extends Equatable {
  final String id;
  final String name;
  final String scientificName;
  final double confidence;
  final String? description;
  final String? habitat;
  final String? audioSample;
  final String? imageUrl;
  final Map<String, dynamic>? additionalInfo;

  const DetectedBirdModel({
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

  /// Creates model from JSON
  factory DetectedBirdModel.fromJson(Map<String, dynamic> json) {
    return DetectedBirdModel(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientific_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      description: json['description'] as String?,
      habitat: json['habitat'] as String?,
      audioSample: json['audio_sample'] as String?,
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
      'description': description,
      'habitat': habitat,
      'audio_sample': audioSample,
      'image_url': imageUrl,
      'additional_info': additionalInfo,
    };
  }

  /// Converts model to domain entity
  DetectedBird toEntity() {
    return DetectedBird(
      id: id,
      name: name,
      scientificName: scientificName,
      confidence: confidence,
      description: description,
      habitat: habitat,
      audioSample: audioSample,
      imageUrl: imageUrl,
      additionalInfo: additionalInfo,
    );
  }

  /// Creates model from prediction result
  factory DetectedBirdModel.fromPrediction({
    required String label,
    required double confidence,
    Map<String, dynamic>? speciesInfo,
  }) {
    final info = speciesInfo ?? {};
    return DetectedBirdModel(
      id: info['id'] as String? ?? label.toLowerCase().replaceAll(' ', '_'),
      name: info['name'] as String? ?? label,
      scientificName: info['scientific_name'] as String? ?? '',
      confidence: confidence,
      description: info['description'] as String?,
      habitat: info['habitat'] as String?,
      audioSample: info['audio_sample'] as String?,
      imageUrl: info['image_url'] as String?,
      additionalInfo: info['additional_info'] as Map<String, dynamic>?,
    );
  }
}
