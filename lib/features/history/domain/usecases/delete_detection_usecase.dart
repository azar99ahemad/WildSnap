import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/history_repository.dart';

/// Usecase for deleting detection records
class DeleteDetectionUsecase {
  final HistoryRepository repository;

  DeleteDetectionUsecase(this.repository);

  /// Deletes a detection record by ID
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteRecord(id);
  }
}
