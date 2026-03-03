import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/history_repository.dart';

/// Usecase for clearing all history
class ClearHistoryUsecase {
  final HistoryRepository repository;

  ClearHistoryUsecase(this.repository);

  /// Clears all history records
  Future<Either<Failure, void>> call() {
    return repository.clearHistory();
  }
}
