import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/image_utils.dart';

/// Prediction result from ML model
class ModelPrediction {
  final String label;
  final double confidence;

  const ModelPrediction({required this.label, required this.confidence});
}

/// Data source for ML model operations
abstract class ModelDatasource {
  /// Loads the image classification model
  Future<void> loadImageModel();

  /// Loads the audio classification model
  Future<void> loadAudioModel();

  /// Runs inference on image data
  Future<List<ModelPrediction>> predictFromImage(
    Uint8List imageData, {
    int numPredictions = 3,
    double minConfidence = 0.1,
  });

  /// Runs inference on spectrogram data
  Future<List<ModelPrediction>> predictFromSpectrogram(
    List<List<double>> spectrogram, {
    int numPredictions = 3,
    double minConfidence = 0.1,
  });

  /// Disposes the models
  Future<void> dispose();

  /// Checks if image model is loaded
  bool get isImageModelLoaded;

  /// Checks if audio model is loaded
  bool get isAudioModelLoaded;
}

/// Implementation of ModelDatasource using TFLite
class ModelDatasourceImpl implements ModelDatasource {
  Interpreter? _imageInterpreter;
  Interpreter? _audioInterpreter;
  List<String>? _imageLabels;
  List<String>? _audioLabels;
  Map<String, dynamic>? _speciesInfo;

  @override
  bool get isImageModelLoaded => _imageInterpreter != null;

  @override
  bool get isAudioModelLoaded => _audioInterpreter != null;

  @override
  Future<void> loadImageModel() async {
    try {
      // Load model
      _imageInterpreter = await Interpreter.fromAsset(
        AppConstants.imageModelPath,
        options: InterpreterOptions()..threads = 4,
      );

      // Load labels
      final labelsData = await rootBundle.loadString(AppConstants.imageLabelsPath);
      _imageLabels = LineSplitter.split(labelsData).toList();

      // Load species info
      await _loadSpeciesInfo();
    } catch (e) {
      throw ModelLoadException('Failed to load image model: $e');
    }
  }

  @override
  Future<void> loadAudioModel() async {
    try {
      // Load model
      _audioInterpreter = await Interpreter.fromAsset(
        AppConstants.audioModelPath,
        options: InterpreterOptions()..threads = 4,
      );

      // Load labels
      final labelsData = await rootBundle.loadString(AppConstants.audioLabelsPath);
      _audioLabels = LineSplitter.split(labelsData).toList();

      // Load species info
      await _loadSpeciesInfo();
    } catch (e) {
      throw ModelLoadException('Failed to load audio model: $e');
    }
  }

  Future<void> _loadSpeciesInfo() async {
    if (_speciesInfo != null) return;
    try {
      final speciesData = await rootBundle.loadString(AppConstants.speciesDataPath);
      _speciesInfo = json.decode(speciesData) as Map<String, dynamic>;
    } catch (e) {
      // Species info is optional, continue without it
      _speciesInfo = {};
    }
  }

  @override
  Future<List<ModelPrediction>> predictFromImage(
    Uint8List imageData, {
    int numPredictions = 3,
    double minConfidence = 0.1,
  }) async {
    if (!isImageModelLoaded) {
      throw const ModelLoadException('Image model not loaded');
    }

    try {
      // Validate image
      if (!ImageUtils.isValidImage(imageData)) {
        throw const CorruptImageException();
      }

      // Run inference in isolate to avoid UI freeze
      final predictions = await _runInferenceInIsolate(
        imageData: imageData,
        interpreter: _imageInterpreter!,
        labels: _imageLabels!,
        inputSize: AppConstants.modelInputSize,
      );

      // Filter and sort results
      final filteredPredictions = predictions
          .where((p) => p.confidence >= minConfidence)
          .toList()
        ..sort((a, b) => b.confidence.compareTo(a.confidence));

      return filteredPredictions.take(numPredictions).toList();
    } catch (e) {
      if (e is CorruptImageException) rethrow;
      throw DetectionException('Image inference failed: $e');
    }
  }

  @override
  Future<List<ModelPrediction>> predictFromSpectrogram(
    List<List<double>> spectrogram, {
    int numPredictions = 3,
    double minConfidence = 0.1,
  }) async {
    if (!isAudioModelLoaded) {
      throw const ModelLoadException('Audio model not loaded');
    }

    try {
      // Prepare input tensor
      final inputShape = _audioInterpreter!.getInputTensor(0).shape;
      final outputShape = _audioInterpreter!.getOutputTensor(0).shape;
      
      // Create input array matching expected shape
      final input = _prepareAudioInput(spectrogram, inputShape);
      final output = List.filled(outputShape[1], 0.0).reshape([1, outputShape[1]]);

      // Run inference
      _audioInterpreter!.run(input, output);

      // Process results
      final predictions = <ModelPrediction>[];
      final results = output[0] as List<double>;
      
      for (var i = 0; i < results.length && i < _audioLabels!.length; i++) {
        if (results[i] >= minConfidence) {
          predictions.add(ModelPrediction(
            label: _audioLabels![i],
            confidence: results[i],
          ));
        }
      }

      predictions.sort((a, b) => b.confidence.compareTo(a.confidence));
      return predictions.take(numPredictions).toList();
    } catch (e) {
      throw AudioException('Audio inference failed: $e');
    }
  }

  List<dynamic> _prepareAudioInput(
    List<List<double>> spectrogram,
    List<int> inputShape,
  ) {
    // Reshape spectrogram to match model input shape
    final height = inputShape[1];
    final width = inputShape[2];
    
    final input = List.generate(
      1,
      (_) => List.generate(
        height,
        (y) => List.generate(
          width,
          (x) {
            if (y < spectrogram.length && x < spectrogram[y].length) {
              return spectrogram[y][x];
            }
            return 0.0;
          },
        ),
      ),
    );
    
    return input;
  }

  Future<List<ModelPrediction>> _runInferenceInIsolate({
    required Uint8List imageData,
    required Interpreter interpreter,
    required List<String> labels,
    required int inputSize,
  }) async {
    // For simplicity, run on main thread with image preprocessing
    // In production, use compute() or Isolate for heavy processing
    
    final inputArray = ImageUtils.imageToInputArray(imageData, inputSize: inputSize);
    final outputShape = interpreter.getOutputTensor(0).shape;
    final output = List.filled(outputShape[1], 0.0).reshape([1, outputShape[1]]);

    interpreter.run(inputArray, output);

    final predictions = <ModelPrediction>[];
    final results = output[0] as List<double>;
    
    for (var i = 0; i < results.length && i < labels.length; i++) {
      predictions.add(ModelPrediction(
        label: labels[i],
        confidence: results[i],
      ));
    }

    return predictions;
  }

  /// Gets species info for a label
  Map<String, dynamic>? getSpeciesInfo(String label) {
    if (_speciesInfo == null) return null;
    final normalizedLabel = label.toLowerCase().replaceAll(' ', '_');
    return _speciesInfo![normalizedLabel] as Map<String, dynamic>?;
  }

  @override
  Future<void> dispose() async {
    _imageInterpreter?.close();
    _audioInterpreter?.close();
    _imageInterpreter = null;
    _audioInterpreter = null;
  }
}
