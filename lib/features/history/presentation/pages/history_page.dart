import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/detection_record.dart';
import '../providers/history_provider.dart';
import '../widgets/history_list_item.dart';
import '../widgets/empty_history_widget.dart';
import '../../../detection/presentation/widgets/skeleton_loader.dart';

/// Page displaying detection history
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load history on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyNotifierProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final filter = ref.read(historyFilterProvider);
      ref.read(historyNotifierProvider.notifier).loadMore(filterType: filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyNotifierProvider);
    final filter = ref.watch(historyFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search species...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  ref.read(historyNotifierProvider.notifier).searchHistory(query);
                },
              )
            : const Text('Detection History'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(historyNotifierProvider.notifier).loadHistory(
                        filterType: filter,
                      );
                }
              });
            },
          ),
          PopupMenuButton<DetectionType?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by type',
            onSelected: (type) {
              ref.read(historyFilterProvider.notifier).state = type;
              ref.read(historyNotifierProvider.notifier).loadHistory(
                    filterType: type,
                  );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All'),
              ),
              const PopupMenuItem(
                value: DetectionType.image,
                child: Text('Images'),
              ),
              const PopupMenuItem(
                value: DetectionType.audio,
                child: Text('Audio'),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear') {
                _showClearConfirmation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(historyNotifierProvider.notifier).loadHistory(
                filterType: filter,
              );
        },
        child: _buildBody(historyState),
      ),
    );
  }

  Widget _buildBody(HistoryState state) {
    return switch (state) {
      HistoryInitial() || HistoryLoading() => const ListSkeletonLoader(),
      HistoryEmpty() => const EmptyHistoryWidget(),
      HistoryError(message: final message) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(message),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(historyNotifierProvider.notifier).loadHistory();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      HistoryLoaded(records: final records, hasMore: final hasMore) ||
      HistoryLoadingMore(records: final records) =>
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: records.length + (state is HistoryLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == records.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HistoryListItem(
                record: records[index],
                onTap: () => _showRecordDetail(records[index]),
                onDelete: () => _deleteRecord(records[index].id),
              ),
            );
          },
        ),
    };
  }

  void _showRecordDetail(DetectionRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Image preview if available
              if (record.imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(record.imagePath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 64),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Species info
              Text(
                record.speciesName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (record.scientificName.isNotEmpty)
                Text(
                  record.scientificName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                ),
              const SizedBox(height: 16),

              // Confidence
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text('Confidence: ${record.confidencePercentage}'),
                ],
              ),
              const SizedBox(height: 8),

              // Detection type
              Row(
                children: [
                  Icon(
                    record.detectionType == DetectionType.image
                        ? Icons.image_outlined
                        : Icons.mic_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    record.detectionType == DetectionType.image
                        ? 'Image Detection'
                        : 'Audio Detection',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Timestamp
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 8),
                  Text(_formatTimestamp(record.timestamp)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _deleteRecord(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(historyNotifierProvider.notifier).deleteRecord(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all detection history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(historyNotifierProvider.notifier).clearHistory();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
