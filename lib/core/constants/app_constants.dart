/// App-wide constants
class AppConstants {
  AppConstants._();

  /// App name
  static const String appName = 'WildSnap Pro';

  /// App version
  static const String appVersion = '1.0.0';

  /// ML Model constants
  static const String imageModelPath = 'assets/models/animal_classifier.tflite';
  static const String audioModelPath = 'assets/models/bird_sound_classifier.tflite';
  static const String imageLabelsPath = 'assets/labels/animal_labels.txt';
  static const String audioLabelsPath = 'assets/labels/bird_labels.txt';
  static const String speciesDataPath = 'assets/species_data/species_info.json';

  /// Image processing constants
  static const int modelInputSize = 224;
  static const int numPredictions = 3;
  static const double minConfidenceThreshold = 0.1;

  /// Audio processing constants
  static const int audioSampleRate = 16000;
  static const int maxRecordingDurationSeconds = 15;
  static const int minRecordingDurationSeconds = 2;
  static const int spectrogramSize = 128;

  /// Storage constants
  static const String historyBoxName = 'detection_history';
  static const String settingsBoxName = 'app_settings';
  static const String speciesBoxName = 'species_cache';
  static const int maxHistoryItems = 1000;
  static const int historyPageSize = 20;

  /// Network constants
  static const String baseUrl = 'https://api.wildsnap.example.com';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  /// Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
