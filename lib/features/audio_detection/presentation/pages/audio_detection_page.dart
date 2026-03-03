import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/audio_detection_result.dart';
import '../providers/audio_detection_provider.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/bird_result_card.dart';

/// Page for audio-based bird detection
class AudioDetectionPage extends ConsumerWidget {
  const AudioDetectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioDetectionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bird Sound Detection'),
        centerTitle: true,
        actions: [
          if (state is AudioDetectionSuccess)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(audioDetectionNotifierProvider.notifier).reset();
              },
              tooltip: 'Reset',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions card
              _buildInstructionsCard(context),
              const SizedBox(height: 24),

              // Main content based on state
              _buildContent(context, state, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'How to Use',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('1. Tap the microphone button to start recording'),
            const SizedBox(height: 4),
            Text(
              '2. Record for ${AppConstants.minRecordingDurationSeconds}-${AppConstants.maxRecordingDurationSeconds} seconds',
            ),
            const SizedBox(height: 4),
            const Text('3. Point your device towards the bird sound source'),
            const SizedBox(height: 4),
            const Text('4. Tap stop to analyze the recording'),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AudioDetectionState state,
    WidgetRef ref,
  ) {
    return switch (state) {
      AudioDetectionInitial() => _buildInitialState(context, ref),
      AudioRecording(duration: final duration) =>
        _buildRecordingState(context, duration, ref),
      AudioDetectionLoading() => _buildLoadingState(context),
      AudioDetectionSuccess(result: final result) =>
        _buildSuccessState(context, result, ref),
      AudioDetectionError(message: final message) =>
        _buildErrorState(context, message, ref),
    };
  }

  Widget _buildInitialState(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Microphone button
        _buildMicrophoneButton(
          context,
          onTap: () {
            ref.read(audioDetectionNotifierProvider.notifier).startRecording();
          },
          isRecording: false,
        ),
        const SizedBox(height: 24),
        Text(
          'Tap to start recording',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildRecordingState(
    BuildContext context,
    Duration duration,
    WidgetRef ref,
  ) {
    final seconds = duration.inSeconds;
    final isMinDurationReached =
        seconds >= AppConstants.minRecordingDurationSeconds;

    return Column(
      children: [
        // Audio visualizer
        const AudioVisualizer(isRecording: true),
        const SizedBox(height: 24),

        // Recording indicator
        _buildMicrophoneButton(
          context,
          onTap: () {
            if (isMinDurationReached) {
              ref
                  .read(audioDetectionNotifierProvider.notifier)
                  .stopRecordingAndDetect();
            }
          },
          isRecording: true,
        ),
        const SizedBox(height: 16),

        // Duration display
        Text(
          '${seconds.toString().padLeft(2, '0')}s / ${AppConstants.maxRecordingDurationSeconds}s',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
        ),
        const SizedBox(height: 8),

        // Status text
        Text(
          isMinDurationReached
              ? 'Tap to stop and analyze'
              : 'Keep recording (min ${AppConstants.minRecordingDurationSeconds}s)...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),

        const SizedBox(height: 24),

        // Cancel button
        TextButton.icon(
          onPressed: () {
            ref.read(audioDetectionNotifierProvider.notifier).cancelRecording();
          },
          icon: const Icon(Icons.close),
          label: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          'Analyzing bird sounds...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'This may take a few seconds',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    AudioDetectionResult result,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Results header
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'Detection Complete',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Processing time: ${result.processingTime.inMilliseconds}ms',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),

        // Results
        if (result.predictions.isEmpty)
          _buildNoDetectionCard(context)
        else
          ...result.predictions.map(
            (bird) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BirdResultCard(bird: bird),
            ),
          ),

        const SizedBox(height: 24),

        // Try again button
        OutlinedButton.icon(
          onPressed: () {
            ref.read(audioDetectionNotifierProvider.notifier).reset();
          },
          icon: const Icon(Icons.replay),
          label: const Text('Detect Another'),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    WidgetRef ref,
  ) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Icon(
          Icons.error_outline,
          size: 64,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          'Detection Failed',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(audioDetectionNotifierProvider.notifier).reset();
          },
          icon: const Icon(Icons.replay),
          label: const Text('Try Again'),
        ),
      ],
    );
  }

  Widget _buildMicrophoneButton(
    BuildContext context, {
    required VoidCallback onTap,
    required bool isRecording,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording
              ? Colors.red.withOpacity(0.1)
              : Theme.of(context).colorScheme.primaryContainer,
          border: Border.all(
            color: isRecording
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
            width: 3,
          ),
        ),
        child: Center(
          child: Icon(
            isRecording ? Icons.stop : Icons.mic,
            size: 48,
            color: isRecording
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildNoDetectionCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.music_off,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No bird sounds detected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try recording in a quieter environment with clear bird sounds',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
