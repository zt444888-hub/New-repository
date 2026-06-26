# MediaMate

A powerful local video/audio format converter for iOS. All conversions happen locally on your device, ensuring complete privacy.

## Features

- 馃幀 **Video Conversion**: Convert videos to MP4, MOV and more
- 馃幍 **Audio Extraction**: Extract audio from videos
- 馃摫 **Privacy First**: 100% local processing, no cloud uploads
- 鈿?**Fast Conversion**: Optimized for speed and quality
- 馃搳 **File Comparison**: See before/after file sizes
- 馃摐 **Conversion History**: Track all your conversions

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
git clone https://github.com/zt444888-hub/New-repository.git
cd New-repository/MediaMate
```

2. Open the project in Xcode:
```bash
open MediaMate.xcodeproj
```

3. Select a simulator or connect a device
4. Press 鈱?R to build and run

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
鈹溾攢鈹€ MediaMateApp.swift          # App entry point
鈹溾攢鈹€ ContentView.swift           # Main navigation
鈹溾攢鈹€ AppState.swift              # State management
鈹溾攢鈹€ ConversionEngine.swift      # Conversion logic
鈹溾攢鈹€ Views/
鈹?  鈹溾攢鈹€ HomeView.swift          # Home screen
鈹?  鈹溾攢鈹€ ConvertSettingsView.swift
鈹?  鈹溾攢鈹€ ProgressView.swift
鈹?  鈹溾攢鈹€ CompleteView.swift
鈹?  鈹溾攢鈹€ HistoryView.swift
鈹?  鈹斺攢鈹€ SettingsView.swift
鈹斺攢鈹€ Components/
    鈹溾攢鈹€ ButtonStyles.swift      # Custom button styles
    鈹溾攢鈹€ FormatChip.swift        # Format selection chip
    鈹斺攢鈹€ SizeCompareCard.swift   # File size comparison
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is for educational purposes. Please ensure compliance with Apple's App Store guidelines before distribution.

## Acknowledgments

- Apple AVFoundation framework
- SwiftUI for beautiful UI
- SF Symbols for icons
