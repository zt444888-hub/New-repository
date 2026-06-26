import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            Section("General") {
                NavigationLink(destination: AboutView()) {
                    Text("About MediaMate")
                }
                NavigationLink(destination: EmptyView()) {
                    HStack {
                        Text("Storage Saved")
                        Spacer()
                        let saved = calculateStorageSaved()
                        Text(saved)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.green)
                    }
                }
            }

            Section("Features") {
                if #available(iOS 15.0, *) {
                    if !StoreManager.shared.isPurchased {
                        NavigationLink(destination: PaywallView()) {
                            HStack {
                                Image(systemName: "crown.fill").foregroundColor(.accent)
                                Text("Unlock Full Version")
                            }
                        }
                    }
                }
                NavigationLink(destination: ConvertedFilesView().environmentObject(appState)) {
                    Text("Converted Files")
                }
            }

            Section("Privacy") {
                HStack {
                    Text("Data Collection")
                    Spacer()
                    Text("None")
                        .font(.caption.bold())
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color.green).foregroundColor(.black).clipShape(Capsule())
                }
                Text("100% on-device processing. No analytics, no tracking, no data collection.")
                    .font(.system(size: 13)).foregroundColor(.textSecondary).padding(.vertical, 4)
                NavigationLink(destination: PrivacyView()) {
                    Text("Privacy Policy")
                }
            }

            Section("Info") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.1.0 (Build 1)")
                        .foregroundColor(.textTertiary)
                }
                HStack {
                    Text("Purchase")
                    Spacer()
                    if #available(iOS 15.0, *) {
                        Text(StoreManager.shared.isPurchased ? "Purchased" : "Not Purchased")
                            .foregroundColor(StoreManager.shared.isPurchased ? .green : .textTertiary)
                    } else {
                        Text("N/A").foregroundColor(.textTertiary)
                    }
                }
            }
        }
        .background(Color.bgPrimary)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func calculateStorageSaved() -> String {
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        guard let contents = try? FileManager.default.contentsOfDirectory(at: docsDir, includingPropertiesForKeys: [.fileSizeKey]) else { return "—" }
        let total = contents.reduce(0) { total, url in
            guard url.lastPathComponent.contains("_converted"),
                  let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                  let size = attrs[.size] as? Int64 else { return total }
            return total + size
        }
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "film").font(.system(size: 64)).foregroundColor(.accent)
                Text("MediaMate").font(.system(size: 24, weight: .bold)).foregroundColor(.textPrimary)
                Text("Video & Audio Tool").font(.system(size: 16)).foregroundColor(.textSecondary)
                Divider().background(Color.separator)
                Text("MediaMate is a powerful media conversion tool that processes everything locally on your device.")
                    .font(.system(size: 14)).foregroundColor(.textSecondary).multilineTextAlignment(.center).padding(.horizontal, 20)
                Text("Version 1.1.0").font(.system(size: 14)).foregroundColor(.textTertiary)
                Text("One-time purchase. No subscription. No ads.")
                    .font(.system(size: 13)).foregroundColor(.accent)
            }.padding(.vertical, 40)
        }.background(Color.bgPrimary).navigationTitle("About")
    }
}

// MARK: - Privacy View

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy").font(.system(size: 20, weight: .bold)).foregroundColor(.textPrimary)
                Text("Last updated: June 2026").font(.system(size: 14)).foregroundColor(.textSecondary)
                Section(title: "No Data Collection") {
                    Text("MediaMate does not collect, store, or transmit any personal data. All media processing happens locally on your device.")
                }
                Section(title: "On-Device Processing") {
                    Text("All video and audio conversions are performed entirely on your iPhone. No files are uploaded to servers.")
                }
                Section(title: "Permissions") {
                    Text("MediaMate only requests access to your photo library when needed to select or save media files.")
                }
                Section(title: "Third-Party Services") {
                    Text("MediaMate does not use any third-party analytics, tracking, or advertising services.")
                }
            }.padding(.horizontal, 20).padding(.vertical, 20)
        }.background(Color.bgPrimary).navigationTitle("Privacy Policy")
    }

    private func Section(title: String, content: () -> Text) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 16, weight: .semibold)).foregroundColor(.textPrimary)
            content().font(.system(size: 14)).foregroundColor(.textSecondary)
        }
    }
}
