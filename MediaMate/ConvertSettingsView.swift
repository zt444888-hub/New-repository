import SwiftUI

struct ConvertSettingsView: View {
    @EnvironmentObject var appState: AppState
    @Binding var navigationPath: NavigationPath
    @State private var conversionStarted = false

    let formats = [""MP4"", ""MOV"", ""M4A"", ""MP3"", ""WAV""]
    let resolutions = [""Original"", ""1080p"", ""720p"", ""480p""]
    let qualityLabels = [""Low"", ""Medium"", ""High"", ""Lossless""]

    var selectedFileName: String {
        appState.currentFile?.lastPathComponent ?? ""Unknown File""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(""Selected File"")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .textCase(.uppercase)

                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.bgElevated)
                                .frame(width: 44, height: 44)
                            Image(systemName: fileIcon)
                                .foregroundColor(.accent)
                                .font(.system(size: 20))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedFileName)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.textPrimary)
                                .lineLimit(1)

                            if let size = getFileSize() {
                                Text(size)
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
                    Text(""Output Format"")
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
                        Text(""Quality"")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .textCase(.uppercase)
                        Spacer()
                        Text(qualityLabels[Int(appState.quality)])
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }

                    Slider(value: .quality, in: 0...3, step: 1)
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
                    Text(""Resolution"")
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
                Button(""Start Conversion"") {
                    startConversion()
                }
                .disabled(conversionStarted)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 20)

                Button(""Cancel"") {
                    navigationPath.removeLast()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.red)
                .padding(.bottom, 8)
            }
            .background(Color.bgPrimary)
        }
        .navigationTitle(""Convert Settings"")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            conversionStarted = false
        }
    }

    private func startConversion() {
        guard let sourceURL = appState.currentFile else { return }
        conversionStarted = true

        if appState.isTestMode {
            appState.engine.progress = 0
            appState.engine.isConverting = true
            appState.conversionProgress = 0
            navigationPath.append(Route.progress)
            return
        }

        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: sourceURL.path)
            if let size = attrs[.size] as? Int64 {
                let fmt = ByteCountFormatter()
                fmt.allowedUnits = [.useMB]
                fmt.countStyle = .file
                appState.originalFileSizeText = fmt.string(fromByteCount: size)
            }
        } catch {
            appState.originalFileSizeText = ""Unknown""
        }

        appState.originalFileName = sourceURL.lastPathComponent
        appState.engine.progress = 0
        appState.engine.isConverting = true
        appState.conversionProgress = 0

        appState.engine.convertFile(at: sourceURL, to: appState.selectedFormat, quality: appState.quality, resolution: appState.selectedResolution) { result in
            DispatchQueue.main.async {
                appState.engine.isConverting = false
                switch result {
                case .success(let outputURL):
                    appState.convertedFileURL = outputURL
                    appState.convertedFile = outputURL
                    appState.engine.progress = 1.0
                    appState.conversionProgress = 1.0

                    do {
                        let attrs = try FileManager.default.attributesOfItem(atPath: outputURL.path)
                        if let size = attrs[.size] as? Int64 {
                            let fmt = ByteCountFormatter()
                            fmt.allowedUnits = [.useMB]
                            fmt.countStyle = .file
                            appState.convertedFileSizeText = fmt.string(fromByteCount: size)
                        }
                    } catch {
                        appState.convertedFileSizeText = ""Unknown""
                    }

                case .failure(let error):
                    print(""Conversion failed: \(error.localizedDescription)"")
                    appState.engine.progress = 0
                }
            }
        }

        navigationPath.append(Route.progress)
    }

    private var fileIcon: String {
        guard let url = appState.currentFile else { return ""doc"" }
        let ext = url.pathExtension.lowercased()
        if [""mov"", ""mp4"", ""avi"", ""mkv""].contains(ext) {
            return ""film""
        } else if [""m4a"", ""mp3"", ""wav"", ""aac""].contains(ext) {
            return ""music.note""
        }
        return ""doc""
    }

    private func getFileSize() -> String? {
        guard let url = appState.currentFile else { return nil }
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? Int64 {
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useMB]
                formatter.countStyle = .file
                return formatter.string(fromByteCount: fileSize)
            }
        } catch {
            print(""Error getting file size: \(error)"")
        }
        return nil
    }
}
