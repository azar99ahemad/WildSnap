import 'package:hive/hive.dart';
import '../../domain/entities/detection_record.dart';

part 'detection_record_model.g.dart';

/// Hive type ID for DetectionType
@HiveType(typeId: 0)
enum DetectionTypeModel {
  @HiveField(0)
  image,
  @HiveField(1)
  audio,
}

/// Data model for detection record (Hive)
@HiveType(typeId: 1)
class DetectionRecordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String speciesName;

  @HiveField(2)
  final String scientificName;

  @HiveField(3)
  final double confidence;

  @HiveField(4)
  final DetectionTypeModel detectionType;

  @HiveField(5)
  final String? imagePath;

  @HiveField(6)
  final String? audioPath;

  @HiveField(7)
  final DateTime timestamp;

  @HiveField(8)
  final Map<String, dynamic>? additionalData;

  DetectionRecordModel({
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

  /// Converts model to domain entity
  DetectionRecord toEntity() {
    return DetectionRecord(
      id: id,
      speciesName: speciesName,
      scientificName: scientificName,
      confidence: confidence,
      detectionType: _toDetectionType(detectionType),
      imagePath: imagePath,
      audioPath: audioPath,
      timestamp: timestamp,
      additionalData: additionalData,
    );
  }

  /// Creates model from domain entity
  factory DetectionRecordModel.fromEntity(DetectionRecord entity) {
    return DetectionRecordModel(
      id: entity.id,
      speciesName: entity.speciesName,
      scientificName: entity.scientificName,
      confidence: entity.confidence,
      detectionType: _fromDetectionType(entity.detectionType),
      imagePath: entity.imagePath,
      audioPath: entity.audioPath,
      timestamp: entity.timestamp,
      additionalData: entity.additionalData,
    );
  }

  static DetectionType _toDetectionType(DetectionTypeModel model) {
    return model == DetectionTypeModel.image
        ? DetectionType.image
        : DetectionType.audio;
  }

  static DetectionTypeModel _fromDetectionType(DetectionType type) {
    return type == DetectionType.image
        ? DetectionTypeModel.image
        : DetectionTypeModel.audio;
  }

  /// Creates model from JSON
  factory DetectionRecordModel.fromJson(Map<String, dynamic> json) {
    return DetectionRecordModel(
      id: json['id'] as String,
      speciesName: json['species_name'] as String,
      scientificName: json['scientific_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      detectionType: json['detection_type'] == 'image'
          ? DetectionTypeModel.image
          : DetectionTypeModel.audio,
      imagePath: json['image_path'] as String?,
      audioPath: json['audio_path'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      additionalData: json['additional_data'] as Map<String, dynamic>?,
    );
  }

  /// Converts model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'species_name': speciesName,
      'scientific_name': scientificName,
      'confidence': confidence,
      'detection_type': detectionType == DetectionTypeModel.image ? 'image' : 'audio',
      'image_path': imagePath,
      'audio_path': audioPath,
      'timestamp': timestamp.toIso8601String(),
      'additional_data': additionalData,
    };
  }
}
