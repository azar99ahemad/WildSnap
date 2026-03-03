import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/detection_record_model.dart';

/// Local data source for history operations
abstract class HistoryLocalDatasource {
  /// Gets paginated history records
  Future<List<DetectionRecordModel>> getHistory({
    int page = 1,
    int pageSize = 20,
    DetectionTypeModel? filterType,
  });

  /// Gets a specific record by ID
  Future<DetectionRecordModel?> getRecordById(String id);

  /// Saves a new detection record
  Future<DetectionRecordModel> saveRecord(DetectionRecordModel record);

  /// Deletes a record by ID
  Future<void> deleteRecord(String id);

  /// Clears all history records
  Future<void> clearHistory();

  /// Gets total count of records
  Future<int> getRecordCount();

  /// Searches records by species name
  Future<List<DetectionRecordModel>> searchRecords(String query);

  /// Initializes the data source
  Future<void> init();
}

/// Implementation of HistoryLocalDatasource using Hive
class HistoryLocalDatasourceImpl implements HistoryLocalDatasource {
  Box<DetectionRecordModel>? _box;

  Future<Box<DetectionRecordModel>> get _getBox async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
    return _box!;
  }

  @override
  Future<void> init() async {
    try {
      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(DetectionTypeModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(DetectionRecordModelAdapter());
      }

      _box = await Hive.openBox<DetectionRecordModel>(AppConstants.historyBoxName);
    } catch (e) {
      throw StorageException('Failed to initialize history storage: $e');
    }
  }

  @override
  Future<List<DetectionRecordModel>> getHistory({
    int page = 1,
    int pageSize = 20,
    DetectionTypeModel? filterType,
  }) async {
    try {
      final box = await _getBox;
      var records = box.values.toList();

      // Filter by type if specified
      if (filterType != null) {
        records = records.where((r) => r.detectionType == filterType).toList();
      }

      // Sort by timestamp (newest first)
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Paginate
      final startIndex = (page - 1) * pageSize;
      if (startIndex >= records.length) {
        return [];
      }

      final endIndex = (startIndex + pageSize).clamp(0, records.length);
      return records.sublist(startIndex, endIndex);
    } catch (e) {
      throw StorageException('Failed to get history: $e');
    }
  }

  @override
  Future<DetectionRecordModel?> getRecordById(String id) async {
    try {
      final box = await _getBox;
      return box.get(id);
    } catch (e) {
      throw StorageException('Failed to get record: $e');
    }
  }

  @override
  Future<DetectionRecordModel> saveRecord(DetectionRecordModel record) async {
    try {
      final box = await _getBox;

      // Check storage limit
      if (box.length >= AppConstants.maxHistoryItems) {
        // Remove oldest record
        final records = box.values.toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        if (records.isNotEmpty) {
          await box.delete(records.first.id);
        }
      }

      await box.put(record.id, record);
      return record;
    } catch (e) {
      throw StorageException('Failed to save record: $e');
    }
  }

  @override
  Future<void> deleteRecord(String id) async {
    try {
      final box = await _getBox;
      await box.delete(id);
    } catch (e) {
      throw StorageException('Failed to delete record: $e');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      final box = await _getBox;
      await box.clear();
    } catch (e) {
      throw StorageException('Failed to clear history: $e');
    }
  }

  @override
  Future<int> getRecordCount() async {
    try {
      final box = await _getBox;
      return box.length;
    } catch (e) {
      throw StorageException('Failed to get record count: $e');
    }
  }

  @override
  Future<List<DetectionRecordModel>> searchRecords(String query) async {
    try {
      final box = await _getBox;
      final lowerQuery = query.toLowerCase();

      return box.values
          .where((r) =>
              r.speciesName.toLowerCase().contains(lowerQuery) ||
              r.scientificName.toLowerCase().contains(lowerQuery))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      throw StorageException('Failed to search records: $e');
    }
  }
}
