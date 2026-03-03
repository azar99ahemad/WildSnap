import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/detection_record.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/delete_detection_usecase.dart';
import '../../domain/usecases/clear_history_usecase.dart';

/// State for history feature
sealed class HistoryState {
  const HistoryState();
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoadingMore extends HistoryState {
  final List<DetectionRecord> records;
  const HistoryLoadingMore(this.records);
}

class HistoryLoaded extends HistoryState {
  final List<DetectionRecord> records;
  final bool hasMore;
  final int currentPage;

  const HistoryLoaded({
    required this.records,
    required this.hasMore,
    required this.currentPage,
  });
}

class HistoryEmpty extends HistoryState {
  const HistoryEmpty();
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
}

/// Notifier for history state
class HistoryNotifier extends StateNotifier<HistoryState> {
  final GetHistoryUsecase _getHistoryUsecase;
  final DeleteDetectionUsecase _deleteDetectionUsecase;
  final ClearHistoryUsecase _clearHistoryUsecase;

  static const int _pageSize = 20;

  HistoryNotifier(
    this._getHistoryUsecase,
    this._deleteDetectionUsecase,
    this._clearHistoryUsecase,
  ) : super(const HistoryInitial());

  /// Loads initial history
  Future<void> loadHistory({DetectionType? filterType}) async {
    state = const HistoryLoading();

    final result = await _getHistoryUsecase(
      GetHistoryParams(page: 1, pageSize: _pageSize, filterType: filterType),
    );

    result.fold(
      (failure) => state = HistoryError(failure.message),
      (records) {
        if (records.isEmpty) {
          state = const HistoryEmpty();
        } else {
          state = HistoryLoaded(
            records: records,
            hasMore: records.length >= _pageSize,
            currentPage: 1,
          );
        }
      },
    );
  }

  /// Loads more history (pagination)
  Future<void> loadMore({DetectionType? filterType}) async {
    final currentState = state;
    if (currentState is! HistoryLoaded || !currentState.hasMore) return;

    state = HistoryLoadingMore(currentState.records);

    final nextPage = currentState.currentPage + 1;
    final result = await _getHistoryUsecase(
      GetHistoryParams(
        page: nextPage,
        pageSize: _pageSize,
        filterType: filterType,
      ),
    );

    result.fold(
      (failure) => state = currentState,
      (newRecords) {
        final allRecords = [...currentState.records, ...newRecords];
        state = HistoryLoaded(
          records: allRecords,
          hasMore: newRecords.length >= _pageSize,
          currentPage: nextPage,
        );
      },
    );
  }

  /// Deletes a record
  Future<void> deleteRecord(String id) async {
    final result = await _deleteDetectionUsecase(id);

    result.fold(
      (failure) {
        // Could show error, but keep current state
      },
      (_) {
        final currentState = state;
        if (currentState is HistoryLoaded) {
          final updatedRecords =
              currentState.records.where((r) => r.id != id).toList();
          if (updatedRecords.isEmpty) {
            state = const HistoryEmpty();
          } else {
            state = HistoryLoaded(
              records: updatedRecords,
              hasMore: currentState.hasMore,
              currentPage: currentState.currentPage,
            );
          }
        }
      },
    );
  }

  /// Clears all history
  Future<void> clearHistory() async {
    final result = await _clearHistoryUsecase();

    result.fold(
      (failure) {
        // Could show error
      },
      (_) => state = const HistoryEmpty(),
    );
  }

  /// Searches history
  Future<void> searchHistory(String query) async {
    if (query.isEmpty) {
      await loadHistory();
      return;
    }

    state = const HistoryLoading();

    final result = await _getHistoryUsecase.search(query);

    result.fold(
      (failure) => state = HistoryError(failure.message),
      (records) {
        if (records.isEmpty) {
          state = const HistoryEmpty();
        } else {
          state = HistoryLoaded(
            records: records,
            hasMore: false,
            currentPage: 1,
          );
        }
      },
    );
  }
}

/// Provider for history notifier
final historyNotifierProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(
    sl<GetHistoryUsecase>(),
    sl<DeleteDetectionUsecase>(),
    sl<ClearHistoryUsecase>(),
  );
});

/// Provider for filter type
final historyFilterProvider = StateProvider<DetectionType?>((ref) => null);
