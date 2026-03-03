import 'package:flutter/material.dart';
import '../../domain/entities/detected_species.dart';

/// Card widget to display detection result
class DetectionResultCard extends StatelessWidget {
  final DetectedSpecies species;
  final String? imagePath;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const DetectionResultCard({
    super.key,
    required this.species,
    this.imagePath,
    this.onTap,
    this.onShare,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final confidenceColor = _getConfidenceColor(species.confidence);

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
                  // Confidence indicator
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: confidenceColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${(species.confidence * 100).toInt()}%',
                        style: TextStyle(
                          color: confidenceColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Species name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          species.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (species.scientificName.isNotEmpty)
                          Text(
                            species.scientificName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Category chip
                  Chip(
                    label: Text(
                      species.category.toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),

              // Description
              if (species.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  species.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Habitat
              if (species.habitat != null) ...[
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
                        species.habitat!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
