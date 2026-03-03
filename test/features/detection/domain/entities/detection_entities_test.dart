import 'package:flutter_test/flutter_test.dart';
import 'package:wildsnap_pro/features/detection/domain/entities/detected_species.dart';
import 'package:wildsnap_pro/features/detection/domain/entities/detection_result.dart';

void main() {
  group('DetectedSpecies', () {
    const species = DetectedSpecies(
      id: 'lion',
      name: 'Lion',
      scientificName: 'Panthera leo',
      confidence: 0.95,
      category: 'mammal',
      description: 'The king of the jungle',
      habitat: 'African savanna',
    );

    test('should return correct confidence percentage', () {
      expect(species.confidencePercentage, '95.0%');
    });

    test('should create a copy with updated fields', () {
      final updated = species.copyWith(confidence: 0.85);
      
      expect(updated.confidence, 0.85);
      expect(updated.name, 'Lion');
      expect(updated.id, 'lion');
    });

    test('should have correct props for equality', () {
      const species2 = DetectedSpecies(
        id: 'lion',
        name: 'Lion',
        scientificName: 'Panthera leo',
        confidence: 0.95,
        category: 'mammal',
        description: 'The king of the jungle',
        habitat: 'African savanna',
      );

      expect(species, equals(species2));
    });
  });

  group('DetectionResult', () {
    const species1 = DetectedSpecies(
      id: 'lion',
      name: 'Lion',
      scientificName: 'Panthera leo',
      confidence: 0.95,
      category: 'mammal',
    );

    const species2 = DetectedSpecies(
      id: 'tiger',
      name: 'Tiger',
      scientificName: 'Panthera tigris',
      confidence: 0.75,
      category: 'mammal',
    );

    final result = DetectionResult(
      predictions: [species1, species2],
      imagePath: '/path/to/image.jpg',
      timestamp: DateTime(2024, 1, 1),
      processingTime: const Duration(milliseconds: 500),
    );

    test('should return top prediction', () {
      expect(result.topPrediction, species1);
    });

    test('should check if has detection', () {
      expect(result.hasDetection, true);
    });

    test('should return sorted predictions', () {
      final sorted = result.sortedPredictions;
      expect(sorted.first.confidence, greaterThan(sorted.last.confidence));
    });

    test('should handle empty predictions', () {
      final emptyResult = DetectionResult(
        predictions: [],
        imagePath: '/path/to/image.jpg',
        timestamp: DateTime.now(),
        processingTime: const Duration(milliseconds: 100),
      );

      expect(emptyResult.hasDetection, false);
      expect(emptyResult.topPrediction, isNull);
    });
  });
}
