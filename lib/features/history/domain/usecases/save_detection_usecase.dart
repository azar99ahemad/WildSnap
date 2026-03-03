import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/detection_record.dart';
import '../repositories/history_repository.dart';

/// Usecase for saving detection records
class SaveDetectionUsecase {
  final HistoryRepository repository;

  SaveDetectionUsecase(this.repository);

  /// Saves a detection record
  Future<Either<Failure, DetectionRecord>> call(DetectionRecord record) {
    return repository.saveRecord(record);
  }
}
