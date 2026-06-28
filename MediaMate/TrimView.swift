import SwiftUI
import AVKit

struct TrimView: View {
    @EnvironmentObject var appState: AppState
    @Binding var navigationPath: NavigationPath

    @State private var player: AVPlayer?
    @State private var startTime: Double = 0
    @State private var endTime: Double = 1
    @State private var duration: Double = 60
    @State private var showTimeError = false

    private let timeFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.minute, .second]
        f.zeroFormattingBehavior = .pad
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            // Video preview
            if let url = appState.currentFile {
                VideoPlayer(player: player)
                    .frame(height: 260)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .onAppear {
                        let p = AVPlayer(url: url)
                        player = p
                        p.pause()
                        let asset = AVAsset(url: url)
                        let dur = CMTimeGetSeconds(asset.duration)
                        if dur.isFinite && dur > 0 {
                            duration = dur
                            endTime = dur
                        }
                    }
                    .onDisappear {
                        player?.pause()
                        player = nil
                    }

                // Time range controls
                VStack(spacing: 12) {
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "video.fill").foregroundColor(.accent)
                            Text("Trim Video").font(.system(size: 13, weight: .semibold)).foregroundColor(.textSecondary).textCase(.uppercase)
                            Spacer()
                        }

                        // Start time slider
                        VStack(spacing: 2) {
                            HStack {
                                Text("Start").font(.system(size: 12)).foregroundColor(.textTertiary)
                                Spacer()
                                Text(formatTime(startTime)).font(.system(size: 13, design: .monospaced)).foregroundColor(.textPrimary)
                            }
                            Slider(value: $startTime, in: 0...(endTime - 1), step: 0.5)
                                .tint(.accent)
                        }

                        // End time slider
                        VStack(spacing: 2) {
                            HStack {
                                Text("End").font(.system(size: 12)).foregroundColor(.textTertiary)
                                Spacer()
                                Text(formatTime(endTime)).font(.system(size: 13, design: .monospaced)).foregroundColor(.textPrimary)
                            }
                            Slider(value: $endTime, in: (startTime + 1)...duration, step: 0.5)
                                .tint(.accent)
                        }

                        // Duration indicator
                        HStack {
                            Image(systemName: "clock").font(.system(size: 11)).foregroundColor(.textTertiary)
                            Text("Selected: \(formatTime(endTime - startTime))")
                                .font(.system(size: 12)).foregroundColor(.accent)
                            Spacer()
                            Text("Total: \(formatTime(duration))")
                                .font(.system(size: 12)).foregroundColor(.textTertiary)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color.bgCard)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Trim info
                if endTime - startTime < duration * 0.95 {
                    HStack(spacing: 6) {
                        Image(systemName: "scissors").font(.system(size: 12)).foregroundColor(.green)
                        Text("Trimming to \(formatTime(endTime - startTime)) of \(formatTime(duration))")
                            .font(.system(size: 12)).foregroundColor(.green)
                    }
                    .padding(.top, 8)
                }
            }

            Spacer()

            // Bottom buttons
            VStack(spacing: 10) {
                PrimaryButton(title: "Continue to Settings", icon: "arrow.right") {
                    if endTime - startTime < 0.5 {
                        showTimeError = true
                        return
                    }
                    appState.trimStartTime = startTime
                    appState.trimEndTime = endTime
                    appState.hasTrimmed = (startTime > 0 || endTime < duration)
                    player?.pause()
                    navigationPath.append(Route.convert)
                }

                SecondaryButton(title: "Skip Trimming", icon: "forward") {
                    appState.hasTrimmed = false
                    player?.pause()
                    navigationPath.append(Route.convert)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color.bgPrimary)
        .navigationTitle("Trim Video")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Selection Too Short", isPresented: $showTimeError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please select at least 0.5 seconds of video.")
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let total = Int(seconds)
        let mins = total / 60
        let secs = total % 60
        return "\(mins):\(String(format: "%02d", secs))"
    }
}
