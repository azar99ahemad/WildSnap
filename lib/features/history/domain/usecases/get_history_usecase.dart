import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/detection_record.dart';
import '../repositories/history_repository.dart';

/// Parameters for getting history
class GetHistoryParams {
  final int page;
  final int pageSize;
  final DetectionType? filterType;

  const GetHistoryParams({
    this.page = 1,
    this.pageSize = 20,
    this.filterType,
  });
}

/// Usecase for getting history records
class GetHistoryUsecase {
  final HistoryRepository repository;

  GetHistoryUsecase(this.repository);

  /// Gets paginated history records
  Future<Either<Failure, List<DetectionRecord>>> call(GetHistoryParams params) {
    return repository.getHistory(
      page: params.page,
      pageSize: params.pageSize,
      filterType: params.filterType,
    );
  }

  /// Gets a specific record by ID
  Future<Either<Failure, DetectionRecord>> getById(String id) {
    return repository.getRecordById(id);
  }

  /// Searches records by species name
  Future<Either<Failure, List<DetectionRecord>>> search(String query) {
    return repository.searchRecords(query);
  }

  /// Gets total count of records
  Future<Either<Failure, int>> getCount() {
    return repository.getRecordCount();
  }
}
