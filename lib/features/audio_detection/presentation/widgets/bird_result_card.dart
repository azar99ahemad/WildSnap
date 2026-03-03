import 'package:flutter/material.dart';
import '../../domain/entities/detected_bird.dart';

/// Card widget to display bird detection result
class BirdResultCard extends StatelessWidget {
  final DetectedBird bird;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const BirdResultCard({
    super.key,
    required this.bird,
    this.onTap,
    this.onShare,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final confidenceColor = _getConfidenceColor(bird.confidence);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Bird icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.flutter_dash,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Bird info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bird.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (bird.scientificName.isNotEmpty)
                          Text(
                            bird.scientificName,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                      ],
                    ),
                  ),

                  // Confidence
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: confidenceColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      bird.confidencePercentage,
                      style: TextStyle(
                        color: confidenceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Description
              if (bird.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  bird.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Habitat
              if (bird.habitat != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.landscape_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        bird.habitat!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Action buttons
              if (onShare != null || onSave != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onSave != null)
                      TextButton.icon(
                        onPressed: onSave,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('Save'),
                      ),
                    if (onShare != null)
                      TextButton.icon(
                        onPressed: onShare,
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Share'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
