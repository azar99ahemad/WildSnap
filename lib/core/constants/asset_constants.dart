/// Asset path constants
class AssetConstants {
  AssetConstants._();

  /// Images
  static const String imagesPath = 'assets/images';
  static const String logoImage = '$imagesPath/logo.png';
  static const String placeholderImage = '$imagesPath/placeholder.png';
  static const String errorImage = '$imagesPath/error.png';
  static const String emptyHistoryImage = '$imagesPath/empty_history.svg';
  static const String noDetectionImage = '$imagesPath/no_detection.svg';
  static const String offlineIndicator = '$imagesPath/offline.svg';
  static const String watermarkImage = '$imagesPath/watermark.png';

  /// Models
  static const String modelsPath = 'assets/models';
  static const String animalModel = '$modelsPath/animal_classifier.tflite';
  static const String birdSoundModel = '$modelsPath/bird_sound_classifier.tflite';

  /// Labels
  static const String labelsPath = 'assets/labels';
  static const String animalLabels = '$labelsPath/animal_labels.txt';
  static const String birdLabels = '$labelsPath/bird_labels.txt';

  /// Species Data
  static const String speciesDataPath = 'assets/species_data';
  static const String speciesInfo = '$speciesDataPath/species_info.json';
}
