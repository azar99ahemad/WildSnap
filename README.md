# WildSnap Pro 🦁🐦

A production-grade Flutter application for detecting animals and birds from images and bird sounds. Built with clean architecture, offline-first approach, and modern state management.

## 📱 Features

### 🖼️ Image Detection
- On-device ML inference using TensorFlow Lite
- Support for both camera and gallery images
- Returns top 3 predictions with confidence scores
- Automatic image compression for better performance
- Background isolate processing to avoid UI freeze

### 🎤 Bird Sound Recognition
- Record audio (2-15 seconds)
- Audio spectrogram conversion
- TFLite audio classification model
- Returns top 3 bird predictions

### 📜 Detection History
- Offline-first storage using Hive
- Paginated history list
- Support for both image and audio detections
- Search, delete, and clear functionality
- Persisted image paths and timestamps

### 📤 Share Results
- Share species name and confidence
- Generate shareable result cards with branding
- Capture widget as PNG

### ⚡ Performance
- Lazy feature initialization
- Model loaded once and cached
- Memory-safe dispose patterns
- Error-safe async operations

## 🏗️ Architecture

This project follows **Clean Architecture** with a **feature-first modular structure**:

```
lib/
├── core/
│   ├── constants/       # App, route, and asset constants
│   ├── di/              # Dependency injection (get_it)
│   ├── error/           # Failures and exceptions
│   ├── network/         # Network info and API client
│   └── utils/           # Image, audio, and datetime utilities
│
├── features/
│   ├── detection/       # Image-based species detection
│   │   ├── data/        # Datasources, models, repositories
│   │   ├── domain/      # Entities, repositories, usecases
│   │   └── presentation/# Pages, widgets, providers
│   │
│   ├── history/         # Detection history management
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── audio_detection/ # Bird sound detection
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── share/           # Share result feature
│       ├── domain/
│       └── presentation/
│
├── app_theme.dart       # Material 3 theming
├── home_page.dart       # Main navigation
└── main.dart            # App entry point
```

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| State Management | Riverpod |
| Dependency Injection | get_it |
| Local Storage | Hive |
| ML Inference | TFLite Flutter |
| Audio Recording | flutter_sound |
| Image Picker | image_picker |
| Image Processing | image package |
| Sharing | share_plus |
| Screenshot | screenshot |
| Network | Dio, connectivity_plus |
| Error Handling | dartz (Either) |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/azar99ahemad/WildSnap.git
cd WildSnap
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code (Hive adapters):
```bash
flutter pub run build_runner build
```

4. Run the app:
```bash
flutter run
```

## 📦 Project Structure

### Core Layer

- **error/**: Custom failures and exceptions with descriptive messages
- **constants/**: App-wide constants for configuration
- **network/**: Network connectivity checking and API client
- **utils/**: Utility classes for image, audio, and date processing
- **di/**: Dependency injection setup using get_it

### Feature Layer

Each feature follows the same structure:

- **data/**: Data sources (local, remote), models, repository implementations
- **domain/**: Business entities, repository interfaces, use cases
- **presentation/**: UI (pages, widgets) and state management (providers)

## 🎨 UI/UX

- Material 3 design system
- Light and dark theme support
- Smooth hero animations
- Skeleton loaders for loading states
- Empty state designs
- Offline indicator badge

## 🛡️ Error Handling

The app handles various error scenarios:

- Corrupt image files
- No detection results
- Audio too noisy
- Model load failures
- Storage failures
- Permission denials
- Network errors

Uses `Either<Failure, Success>` pattern from dartz for functional error handling.

## 📝 Testing

Run tests:
```bash
flutter test
```

Test coverage includes:
- Entity tests
- Failure/Exception tests
- Utility function tests

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.