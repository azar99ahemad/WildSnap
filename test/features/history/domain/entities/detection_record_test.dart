import 'package:flutter_test/flutter_test.dart';
import 'package:wildsnap_pro/features/history/domain/entities/detection_record.dart';

void main() {
  group('DetectionRecord', () {
    final record = DetectionRecord(
      id: 'record_1',
      speciesName: 'Lion',
      scientificName: 'Panthera leo',
      confidence: 0.95,
      detectionType: DetectionType.image,
      imagePath: '/path/to/image.jpg',
      timestamp: DateTime(2024, 1, 1),
    );

    test('should return correct confidence percentage', () {
      expect(record.confidencePercentage, '95.0%');
    });

    test('should create a copy with updated fields', () {
      final updated = record.copyWith(confidence: 0.85);
      
      expect(updated.confidence, 0.85);
      expect(updated.speciesName, 'Lion');
      expect(updated.id, 'record_1');
    });

    test('should have correct props for equality', () {
      final record2 = DetectionRecord(
        id: 'record_1',
        speciesName: 'Lion',
        scientificName: 'Panthera leo',
        confidence: 0.95,
        detectionType: DetectionType.image,
        imagePath: '/path/to/image.jpg',
        timestamp: DateTime(2024, 1, 1),
      );

      expect(record, equals(record2));
    });

    test('should support audio detection type', () {
      final audioRecord = DetectionRecord(
        id: 'record_2',
        speciesName: 'Sparrow',
        scientificName: 'Passer domesticus',
        confidence: 0.8,
        detectionType: DetectionType.audio,
        audioPath: '/path/to/audio.wav',
        timestamp: DateTime.now(),
      );

      expect(audioRecord.detectionType, DetectionType.audio);
      expect(audioRecord.audioPath, '/path/to/audio.wav');
      expect(audioRecord.imagePath, isNull);
    });
  });
}
