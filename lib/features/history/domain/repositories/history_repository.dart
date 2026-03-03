import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/detection_record.dart';

/// Repository interface for history operations
abstract class HistoryRepository {
  /// Gets paginated history records
  Future<Either<Failure, List<DetectionRecord>>> getHistory({
    int page = 1,
    int pageSize = 20,
    DetectionType? filterType,
  });

  /// Gets a specific record by ID
  Future<Either<Failure, DetectionRecord>> getRecordById(String id);

  /// Saves a new detection record
  Future<Either<Failure, DetectionRecord>> saveRecord(DetectionRecord record);

  /// Deletes a record by ID
  Future<Either<Failure, void>> deleteRecord(String id);

  /// Clears all history records
  Future<Either<Failure, void>> clearHistory();

  /// Gets total count of records
  Future<Either<Failure, int>> getRecordCount();

  /// Searches records by species name
  Future<Either<Failure, List<DetectionRecord>>> searchRecords(String query);
}
