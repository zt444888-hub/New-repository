import SwiftUI

struct ConvertedFilesView: View {
    @EnvironmentObject var appState: AppState
    @State private var files: [(url: URL, date: Date)] = []
    @State private var totalSaved: Int64 = 0

    var body: some View {
        List {
            if files.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray").font(.system(size: 48)).foregroundColor(.textTertiary)
                    Text("No converted files").font(.system(size: 16)).foregroundColor(.textSecondary)
                    Text("Your converted files will appear here").font(.system(size: 14)).foregroundColor(.textTertiary)
                }.frame(maxWidth: .infinity).padding(.vertical, 60).listRowBackground(Color.bgPrimary)
            } else {
                Section {
                    HStack {
                        Text("Total space saved").font(.system(size: 14)).foregroundColor(.textSecondary)
                        Spacer()
                        Text(ByteCountFormatter.string(fromByteCount: totalSaved, countStyle: .file))
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.green)
                    }.padding(.vertical, 4)
                }.listRowBackground(Color.bgCard)

                ForEach(files, id: \.url) { file in
                    HStack(spacing: 12) {
                        Image(systemName: iconForFile(file.url)).font(.system(size: 22)).foregroundColor(.accent).frame(width: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(file.url.lastPathComponent).font(.system(size: 15, weight: .medium)).foregroundColor(.textPrimary).lineLimit(1)
                            HStack(spacing: 4) {
                                if let attrs = try? FileManager.default.attributesOfItem(atPath: file.url.path),
                                   let size = attrs[.size] as? Int64 {
                                    Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file)).font(.system(size: 12)).foregroundColor(.textTertiary)
                                }
                                Text("· \(file.url.pathExtension.uppercased())").font(.system(size: 12)).foregroundColor(.textTertiary)
                            }
                        }
                        Spacer()
                        Button { shareFile(file.url) } label: {
                            Image(systemName: "square.and.arrow.up").foregroundColor(.accent)
                        }.buttonStyle(.plain)
                    }.padding(.vertical, 8)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { deleteFile(file.url) } label: { Label("Delete", systemImage: "trash") }
                    }.listRowBackground(Color.bgCard)
                }
            }
        }
        .scrollContentBackground(.hidden).background(Color.bgPrimary)
        .navigationTitle("Converted Files").navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadFiles)
    }

    private func loadFiles() {
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        guard let contents = try? FileManager.default.contentsOfDirectory(at: docsDir, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]) else { return }
        files = contents.filter { $0.lastPathComponent.contains("_converted") }.compactMap { url in
            guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                  let modDate = attrs[.modificationDate] as? Date else { return nil }
            return (url, modDate)
        }.sorted { $0.date > $1.date }
        totalSaved = files.reduce(0) { $0 + ((try? FileManager.default.attributesOfItem(atPath: $1.url.path))?[.size] as? Int64 ?? 0) }
    }

    private func deleteFile(_ url: URL) { try? FileManager.default.removeItem(at: url); loadFiles() }
    private func shareFile(_ url: URL) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController { root.present(vc, animated: true) }
    }
    private func iconForFile(_ url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "mp4","mov": return "film"; case "m4a","mp3","wav": return "music.note"
        case "gif": return "play.rectangle"; case "jpg","jpeg": return "photo"; default: return "doc"
        }
    }
}
