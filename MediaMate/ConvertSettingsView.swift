import SwiftUI

struct ConvertSettingsView: View {
    @EnvironmentObject var appState: AppState
    @Binding var navigationPath: NavigationPath
    @State private var selectedPreset: Preset? = nil
    @State private var conversionStarted = false

    let formats = ["MP4", "MOV", "GIF", "M4A", "AAC", "WAV", "JPEG", "PNG"]
    let resolutions = ["Original", "1080p", "720p", "480p"]
    let qualityLabels = ["Low", "Medium", "High", "Lossless"]

    var selectedFileName: String {
        appState.currentFile?.lastPathComponent ?? "Unknown File"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Presets picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Preset")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .textCase(.uppercase)

                    NavigationLink(destination: PresetsView(selectedPreset: $selectedPreset)) {
                        HStack {
                            Image(systemName: selectedPreset?.icon ?? "wand.and.stars")
                                .foregroundColor(.accent)
                            Text(selectedPreset?.name ?? "Select a preset...")
                                .foregroundColor(selectedPreset != nil ? .textPrimary : .textTertiary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.textTertiary)
                                .font(.system(size: 12))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(Color.bgCard)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected File")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .textCase(.uppercase)

                    HStack(spacing: 12) {
                        VideoThumbnailView(url: appState.currentFile, size: 44)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedFileName)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.textPrimary)
                                .lineLimit(1)

                            if let url = appState.currentFile {
                                Text(FileUtilities.formatFileSize(url.path))
                                    .font(.system(size: 12))
                                    .foregroundColor(.textTertiary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color.bgCard)
                    .cornerRadius(12)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Output Format")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .textCase(.uppercase)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(formats, id: \.self) { fmt in
                                FormatChip(label: fmt, selected: appState.selectedFormat == fmt) {
                                    withAnimation {
                                        appState.selectedFormat = fmt
                                    }
                                }
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Quality")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .textCase(.uppercase)
                        Spacer()
                        Text(qualityLabels[Int(appState.quality)])
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }

                    Slider(value: $appState.quality, in: 0...3, step: 1)
                        .tint(.accent)
                        .padding(.vertical, 4)

                    HStack {
                        ForEach(qualityLabels, id: \.self) { label in
                            Text(label)
                                .font(.system(size: 11))
                                .foregroundColor(.textTertiary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Resolution")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .textCase(.uppercase)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(resolutions, id: \.self) { res in
                            ResolutionChip(label: res, selected: appState.selectedResolution == res) {
                                withAnimation {
                                    appState.selectedResolution = res
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(Color.bgPrimary)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                Button("Start Conversion") {
                    startConversion()
                }
                .disabled(conversionStarted)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 20)

                Button("Cancel") {
                    navigationPath.removeLast()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.red)
                .padding(.bottom, 8)
            }
            .background(Color.bgPrimary)
        }
        .navigationTitle("Convert Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            conversionStarted = false
        }
    }

    private func startConversion() {
        // Apply preset values if selected
        if let preset = selectedPreset {
            appState.selectedFormat = preset.format
            appState.selectedResolution = preset.resolution
            appState.quality = preset.quality
        }
        guard let sourceURL = appState.currentFile else { return }
        conversionStarted = true

        if appState.isTestMode {
            appState.engine.progress = 0
            appState.engine.isConverting = true
            appState.conversionProgress = 0
            navigationPath.append(Route.progress)
            return
        }

        appState.originalFileSizeText = FileUtilities.formatFileSize(sourceURL.path)

        appState.originalFileName = sourceURL.lastPathComponent
        appState.engine.progress = 0
        appState.engine.isConverting = true
        appState.conversionProgress = 0

        appState.engine.convertFile(at: sourceURL, to: appState.selectedFormat, quality: appState.quality, resolution: appState.selectedResolution) { result in
            DispatchQueue.main.async {
                appState.engine.isConverting = false
                switch result {
                case .success(let outputURL):

                    appState.convertedFile = outputURL
                    appState.engine.progress = 1.0
                    appState.conversionProgress = 1.0

                    appState.convertedFileSizeText = FileUtilities.formatFileSize(outputURL.path)

                case .failure(let error):
                    print("Conversion failed: \(error.localizedDescription)")
                    appState.engine.progress = 0
                }
            }
        }

        navigationPath.append(Route.progress)
    }

    private var fileIcon: String {
        guard let url = appState.currentFile else { return "doc" }
        let ext = url.pathExtension.lowercased()
        if ["mov", "mp4", "avi", "mkv"].contains(ext) {
            return "film"
        } else if ["m4a", "mp3", "wav", "aac"].contains(ext) {
            return "music.note"
        }
        return "doc"
    }

}

