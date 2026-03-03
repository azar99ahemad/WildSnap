import 'dart:math';
import 'package:flutter/material.dart';

/// Audio visualizer widget showing animated bars
class AudioVisualizer extends StatefulWidget {
  final bool isRecording;
  final int barCount;
  final double maxHeight;

  const AudioVisualizer({
    super.key,
    required this.isRecording,
    this.barCount = 20,
    this.maxHeight = 100,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  List<double> _barHeights = [];

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(widget.barCount, (_) => 0.3);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(_updateBars);

    if (widget.isRecording) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _controller.repeat();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _controller.stop();
      setState(() {
        _barHeights = List.generate(widget.barCount, (_) => 0.3);
      });
    }
  }

  void _updateBars() {
    if (widget.isRecording) {
      setState(() {
        _barHeights = List.generate(
          widget.barCount,
          (_) => 0.2 + _random.nextDouble() * 0.8,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.maxHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          widget.barCount,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 6,
            height: widget.maxHeight * _barHeights[index],
            decoration: BoxDecoration(
              color: widget.isRecording
                  ? Colors.red.withOpacity(0.7)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
