import 'dart:math';
import 'dart:typed_data';

/// Utility class for audio processing operations
class AudioUtils {
  AudioUtils._();

  /// Converts raw audio samples to spectrogram
  static List<List<double>> audioToSpectrogram(
    List<double> audioSamples, {
    int fftSize = 512,
    int hopSize = 256,
    int numMelBins = 128,
    int sampleRate = 16000,
  }) {
    final numFrames = ((audioSamples.length - fftSize) / hopSize).floor() + 1;
    final spectrogram = <List<double>>[];

    for (var frame = 0; frame < numFrames; frame++) {
      final start = frame * hopSize;
      final end = start + fftSize;
      if (end > audioSamples.length) break;

      final frameData = audioSamples.sublist(start, end);
      final windowed = _applyHannWindow(frameData);
      final magnitudes = _computeFFTMagnitudes(windowed);
      final melSpec = _applyMelFilterbank(
        magnitudes,
        numMelBins: numMelBins,
        sampleRate: sampleRate,
        fftSize: fftSize,
      );

      spectrogram.add(melSpec);
    }

    return spectrogram;
  }

  /// Applies Hann window to audio frame
  static List<double> _applyHannWindow(List<double> frame) {
    final n = frame.length;
    return List.generate(n, (i) {
      final window = 0.5 * (1 - cos(2 * pi * i / (n - 1)));
      return frame[i] * window;
    });
  }

  /// Computes FFT magnitudes (simplified DFT for demonstration)
  static List<double> _computeFFTMagnitudes(List<double> frame) {
    final n = frame.length;
    final halfN = n ~/ 2;
    final magnitudes = <double>[];

    for (var k = 0; k < halfN; k++) {
      double real = 0;
      double imag = 0;

      for (var t = 0; t < n; t++) {
        final angle = 2 * pi * k * t / n;
        real += frame[t] * cos(angle);
        imag -= frame[t] * sin(angle);
      }

      magnitudes.add(sqrt(real * real + imag * imag));
    }

    return magnitudes;
  }

  /// Applies mel filterbank to FFT magnitudes
  static List<double> _applyMelFilterbank(
    List<double> magnitudes, {
    required int numMelBins,
    required int sampleRate,
    required int fftSize,
  }) {
    final melFilters = _createMelFilterbank(
      numMelBins: numMelBins,
      sampleRate: sampleRate,
      fftSize: fftSize,
      numFreqBins: magnitudes.length,
    );

    final melSpec = <double>[];
    for (var i = 0; i < numMelBins; i++) {
      double sum = 0;
      for (var j = 0; j < magnitudes.length; j++) {
        sum += magnitudes[j] * melFilters[i][j];
      }
      // Apply log compression
      melSpec.add(log(max(sum, 1e-10)));
    }

    return melSpec;
  }

  /// Creates mel filterbank matrix
  static List<List<double>> _createMelFilterbank({
    required int numMelBins,
    required int sampleRate,
    required int fftSize,
    required int numFreqBins,
  }) {
    final maxFreq = sampleRate / 2;
    final melMax = _hzToMel(maxFreq);
    final melMin = _hzToMel(0.0);
    final melPoints = List.generate(
      numMelBins + 2,
      (i) => _melToHz(melMin + (melMax - melMin) * i / (numMelBins + 1)),
    );

    final binPoints = melPoints
        .map((hz) => (hz * fftSize / sampleRate).floor())
        .toList();

    final filters = List.generate(numMelBins, (i) {
      final filter = List.filled(numFreqBins, 0.0);

      for (var j = binPoints[i]; j < binPoints[i + 1] && j < numFreqBins; j++) {
        filter[j] = (j - binPoints[i]) / (binPoints[i + 1] - binPoints[i]);
      }

      for (var j = binPoints[i + 1]; j < binPoints[i + 2] && j < numFreqBins; j++) {
        filter[j] = (binPoints[i + 2] - j) / (binPoints[i + 2] - binPoints[i + 1]);
      }

      return filter;
    });

    return filters;
  }

  /// Converts Hz to Mel scale
  /// Uses the O'Shaughnessy formula: mel = 2595 * log10(1 + hz / 700)
  /// Constants 2595 and 700 are standard mel scale conversion parameters
  static double _hzToMel(double hz) => 2595 * log(1 + hz / 700) / ln10;

  /// Converts Mel scale to Hz
  /// Inverse of _hzToMel: hz = 700 * (10^(mel / 2595) - 1)
  /// Constants 2595 and 700 are standard mel scale conversion parameters
  static double _melToHz(double mel) => 700 * (pow(10, mel / 2595) - 1);

  /// Normalizes audio samples to -1.0 to 1.0 range
  static List<double> normalizeAudio(List<double> samples) {
    final maxAbs = samples.map((s) => s.abs()).reduce(max);
    if (maxAbs == 0) return samples;
    return samples.map((s) => s / maxAbs).toList();
  }

  /// Checks if audio signal is too noisy
  static bool isAudioTooNoisy(List<double> samples, {double threshold = 0.8}) {
    final normalizedSamples = normalizeAudio(samples);
    final rms = sqrt(
      normalizedSamples.map((s) => s * s).reduce((a, b) => a + b) /
          normalizedSamples.length,
    );
    return rms > threshold;
  }

  /// Converts bytes to audio samples (16-bit PCM)
  static List<double> bytesToSamples(Uint8List bytes) {
    final samples = <double>[];
    for (var i = 0; i < bytes.length - 1; i += 2) {
      final sample = (bytes[i] | (bytes[i + 1] << 8));
      // Convert to signed 16-bit
      final signedSample = sample > 32767 ? sample - 65536 : sample;
      samples.add(signedSample / 32768.0);
    }
    return samples;
  }
}
