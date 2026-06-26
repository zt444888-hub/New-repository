# MediaMate

A powerful local video/audio format converter for iOS. All conversions happen locally on your device, ensuring complete privacy.

## Features

- 🎬 **Video Conversion**: Convert videos to MP4, MOV and more
- 🎵 **Audio Extraction**: Extract audio from videos
- 📱 **Privacy First**: 100% local processing, no cloud uploads
- ⚡ **Fast Conversion**: Optimized for speed and quality
- 📊 **File Comparison**: See before/after file sizes
- 📜 **Conversion History**: Track all your conversions

## Requirements

- iOS 18+
- Xcode 16+

## Getting Started

### Prerequisites

- macOS with Xcode installed
- Apple Developer account (for testing on real devices)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/MediaMate.git
cd MediaMate
```

2. Open the project in Xcode:
```bash
open MediaMate.xcodeproj
```

3. Select a simulator or connect a device
4. Press ⌘+R to build and run

## Usage

1. **Choose a File**: Select from Photos or Files app
2. **Configure Settings**: Choose output format, quality, and resolution
3. **Start Conversion**: Watch the progress as your file is converted
4. **Save or Share**: Save to Photos or share with other apps

## Testing

The app includes a Test Mode for development purposes:

1. Tap "Enable Test Mode" on the home screen
2. Mock files will be automatically generated
3. Select "Choose from Photos" or "Choose from Files" to test the conversion flow

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for detailed testing instructions.

## Architecture

```
MediaMate/
├── MediaMateApp.swift          # App entry point
├── ContentView.swift           # Main navigation
├── AppState.swift              # State management
├── ConversionEngine.swift      # Conversion logic
├── Views/
│   ├── HomeView.swift          # Home screen
│   ├── ConvertSettingsView.swift
│   ├── ProgressView.swift
│   ├── CompleteView.swift
│   ├── HistoryView.swift
│   └── SettingsView.swift
└── Components/
    ├── ButtonStyles.swift      # Custom button styles
    ├── FormatChip.swift        # Format selection chip
    └── SizeCompareCard.swift   # File size comparison
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is for educational purposes. Please ensure compliance with Apple's App Store guidelines before distribution.

## Acknowledgments

- Apple AVFoundation framework
- SwiftUI for beautiful UI
- SF Symbols for icons