import SwiftUI

struct CompleteView: View {
    @EnvironmentObject var appState: AppState
    @Binding var navigationPath: NavigationPath
    @State private var showCheck = false

    private var beforeSize: String {
        appState.originalFileSizeText.isEmpty ? ""128.0 MB"" : appState.originalFileSizeText
    }

    private var afterSize: String {
        appState.convertedFileSizeText.isEmpty ? ""48.3 MB"" : appState.convertedFileSizeText
    }

    private var savedPercent: String {
        guard let beforeVal = parseSize(beforeSize),
              let afterVal = parseSize(afterSize),
              beforeVal > 0 else { return ""-62%"" }
        let pct = (1 - afterVal / beforeVal) * 100
        return String(format: ""%.0f%%"", -pct)
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: ""checkmark.circle.fill"")
                .font(.system(size: 72))
                .foregroundColor(.green)
                .scaleEffect(showCheck ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCheck)

            Text(""Conversion Complete"")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.textPrimary)

            SizeCompareCard(before: beforeSize, after: afterSize, saved: savedPercent)

            VStack(spacing: 10) {
                PrimaryButton(title: ""Share"", icon: ""square.and.arrow.up"") {
                    shareFile()
                }

                SecondaryButton(title: ""Save to Photos"", icon: ""square.and.arrow.down"") {
                    saveToPhotos()
                }

                Button(""Convert Another"") {
                    appState.clearCurrentConversion()
                    navigationPath = NavigationPath()
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.bgCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accent, lineWidth: 1)
                )
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 20)
        .background(Color.bgPrimary)
        .navigationTitle("""")
        .navigationBarHidden(true)
        .onAppear {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            showCheck = true
        }
    }

    private func parseSize(_ size: String) -> Double? {
        let clean = size.replacingOccurrences(of: "" MB"", with: """").replacingOccurrences(of: "" GB"", with: """")
        guard let val = Double(clean) else { return nil }
        if size.contains(""GB"") { return val * 1024 }
        return val
    }

    private func shareFile() {
        guard let url = appState.convertedFile else {
            guard let url2 = appState.convertedFileURL else { return }
            let activityVC = UIActivityViewController(activityItems: [url2], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                scene.windows.first?.rootViewController?.present(activityVC, animated: true)
            }
            return
        }

        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.first?.rootViewController?.present(activityVC, animated: true)
        }
    }

    private func saveToPhotos() {
        guard let url = appState.convertedFile ?? appState.convertedFileURL else { return }
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { success, error in
                if success { print(""Saved to photos"") }
            }
        }
    }
}
