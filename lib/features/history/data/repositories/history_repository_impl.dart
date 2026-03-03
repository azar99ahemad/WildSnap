import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/detection_record.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';
import '../models/detection_record_model.dart';

/// Implementation of HistoryRepository
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDatasource localDatasource;

  HistoryRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, List<DetectionRecord>>> getHistory({
    int page = 1,
    int pageSize = 20,
    DetectionType? filterType,
  }) async {
    try {
      final records = await localDatasource.getHistory(
        page: page,
        pageSize: pageSize,
        filterType: filterType != null
            ? (filterType == DetectionType.image
                ? DetectionTypeModel.image
                : DetectionTypeModel.audio)
            : null,
      );
      return Right(records.map((r) => r.toEntity()).toList());
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(StorageFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, DetectionRecord>> getRecordById(String id) async {
    try {
      final record = await localDatasource.getRecordById(id);
      if (record == null) {
        return const Left(StorageFailure(message: 'Record not found'));
      }
      return Right(record.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(StorageFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, DetectionRecord>> saveRecord(DetectionRecord record) async {
    try {
      final model = DetectionRecordModel.fromEntity(record);
      final saved = await localDatasource.saveRecord(model);
      return Right(saved.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(StorageFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecord(String id) async {
    try {
      await localDatasource.deleteRecord(id);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(StorageFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await localDatasource.clearHistory();
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(StorageFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getRecordCount() async {
    try {
      final count = await localDatasource.getRecordCount();
      return Right(count);
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(StorageFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DetectionRecord>>> searchRecords(String query) async {
    try {
      final records = await localDatasource.searchRecords(query);
      return Right(records.map((r) => r.toEntity()).toList());
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(StorageFailure(message: 'Unexpected error: $e'));
    }
  }
}
