# Bilingual Reader

Bilingual Reader is a Flutter-based application designed to help language learners improve their reading skills by providing a seamless bilingual reading experience. It allows users to read texts with instant translations, manage custom dictionaries, and practice vocabulary.

![App Logo](assets/images/bilingual_reader_logo.png)

## Features

*   **Bilingual Reading:** Read texts with side-by-side or interlinear translations (feature in progress).
*   **Custom Dictionaries:** Create and manage your own word lists.
*   **Smart Import:** Import word lists from JSON files or paste JSON content directly.
*   **Vocabulary Practice:** Review words from your custom lists.
*   **Cross-Platform:** Optimized for Android and Windows.

## Supported Platforms

*   **Android:** Fully supported (Phone & Tablet).
*   **Windows:** Fully supported (Desktop).
*   *iOS / macOS / Linux:* Not currently supported or tested.

## Installation

### Android
You can download the latest APK from our [Releases Page](https://github.com/Managed-Informative-Data/BilingualReader/releases).
*   **Google Play Store:** [Coming Soon](#)

### Windows
Download the installer (`.exe`) from our [Releases Page](https://github.com/Managed-Informative-Data/BilingualReader/releases).

## Usage

1.  **Dictionaries:** Go to the Dictionary tab to create a new list or import one.
    *   *Format for JSON Import:*
        ```json
        {
          "name": "My List",
          "words": [
            {
              "word": "hello",
              "translation": "bonjour",
              "pronunciation": "bɔ̃ʒuʁ"
            }
          ]
        }
        ```
2.  **Reading:** (Instructions to be added as feature matures).
3.  **Settings:** Access contact information and app settings.

## Development

This project is built with Flutter.

### Prerequisites
*   Flutter SDK
*   Dart SDK
*   Visual Studio (for Windows build)
*   Android Studio (for Android build)

### Build
```bash
# Run on Windows
flutter run -d windows

# Build for Windows
flutter build windows

# Build for Android
flutter build apk
```

## Contact

*   **Email:** contact@managedinformativedata.com
*   **GitHub:** [Managed-Informative-Data](https://github.com/Managed-Informative-Data)
*   **LinkedIn:** [Tristan Gerber](https://www.linkedin.com/in/tristan-gerber-8698b5231/)

## License

Copyright (C) 2025 Managed Informative Data. All rights reserved.
