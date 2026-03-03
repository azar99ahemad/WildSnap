import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/detection_result.dart';
import '../../domain/usecases/detect_species_usecase.dart';

/// State for detection feature
sealed class DetectionState {
  const DetectionState();
}

class DetectionInitial extends DetectionState {
  const DetectionInitial();
}

class DetectionLoading extends DetectionState {
  const DetectionLoading();
}

class DetectionSuccess extends DetectionState {
  final DetectionResult result;
  const DetectionSuccess(this.result);
}

class DetectionError extends DetectionState {
  final String message;
  const DetectionError(this.message);
}

/// Notifier for detection state
class DetectionNotifier extends StateNotifier<DetectionState> {
  final DetectSpeciesUsecase _detectSpeciesUsecase;

  DetectionNotifier(this._detectSpeciesUsecase) : super(const DetectionInitial());

  /// Detects species from image data
  Future<void> detectFromImage(Uint8List imageData) async {
    state = const DetectionLoading();

    final result = await _detectSpeciesUsecase(
      DetectSpeciesParams(imageData: imageData),
    );

    result.fold(
      (failure) => state = DetectionError(failure.message),
      (detection) => state = DetectionSuccess(detection),
    );
  }

  /// Detects species from image file path
  Future<void> detectFromFile(String imagePath) async {
    state = const DetectionLoading();

    final result = await _detectSpeciesUsecase(
      DetectSpeciesParams(imagePath: imagePath),
    );

    result.fold(
      (failure) => state = DetectionError(failure.message),
      (detection) => state = DetectionSuccess(detection),
    );
  }

  /// Resets state to initial
  void reset() {
    state = const DetectionInitial();
  }
}

/// Provider for detection notifier
final detectionNotifierProvider =
    StateNotifierProvider<DetectionNotifier, DetectionState>((ref) {
  return DetectionNotifier(sl<DetectSpeciesUsecase>());
});

/// Provider for selected image data
final selectedImageProvider = StateProvider<Uint8List?>((ref) => null);

/// Provider for selected image path
final selectedImagePathProvider = StateProvider<String?>((ref) => null);
