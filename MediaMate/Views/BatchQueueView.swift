import SwiftUI

struct BatchItem: Identifiable {
    let id = UUID()
    let url: URL
    var fileName: String { url.lastPathComponent }
    var status: BatchStatus = .pending
    var outputURL: URL?
    var error: String?
}

enum BatchStatus {
    case pending, converting, completed, failed
}

struct BatchQueueView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var items: [BatchItem] = []
    @State private var currentIndex = 0
    @State private var isProcessing = false
    @State private var completedCount = 0

    let format: String
    let quality: Double
    let resolution: String

    init(format: String = "MP4", quality: Double = 2, resolution: String = "Original") {
        self.format = format
        self.quality = quality
        self.resolution = resolution
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                Text("Batch Conversion")
                    .font(.system(size: 22, weight: .bold)).foregroundColor(.textPrimary)
                Text("\(completedCount) of \(items.count) completed")
                    .font(.system(size: 14)).foregroundColor(.textSecondary)
                if isProcessing {
                    SwiftUI.ProgressView()
                        .tint(.accent)
                        .padding(.top, 8)
                }
            }
            .padding(.vertical, 20)

            // Items list
            if items.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray").font(.system(size: 48)).foregroundColor(.textTertiary)
                    Text("No files selected").font(.system(size: 16)).foregroundColor(.textSecondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                            BatchRow(index: idx + 1, item: item)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            // Actions
            VStack(spacing: 10) {
                if !isProcessing && completedCount == items.count && !items.isEmpty {
                    PrimaryButton(title: "Done", icon: "checkmark") {
                        dismiss()
                    }
                } else if !isProcessing && items.isEmpty {
                    // Show nothing
                } else if !isProcessing {
                    PrimaryButton(title: "Start Batch", icon: "play.fill") {
                        startBatch()
                    }
                } else {
                    SecondaryButton(title: "Cancel", icon: "xmark") {
                        appState.engine.cancel()
                        isProcessing = false
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color.bgPrimary)
        .onAppear { loadItems() }
    }

    private func loadItems() {
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: docsDir, includingPropertiesForKeys: nil
        ) else { return }
        // Pick files that have "_converted" suffix (mock files or previous results)
        let files = contents.filter { !$0.lastPathComponent.contains("_converted") }
        if files.isEmpty {
            // Fallback: generate mock files
            MockDataGenerator.shared.setupMockFiles()
            items = MockDataGenerator.shared.getMockFiles().map { BatchItem(url: $0) }
        } else {
            items = files.map { BatchItem(url: $0) }
        }
    }

    private func startBatch() {
        guard !items.isEmpty else { return }
        isProcessing = true
        completedCount = 0
        processNext()
    }

    private func processNext() {
        guard currentIndex < items.count else {
            isProcessing = false
            return
        }

        items[currentIndex].status = .converting
        let item = items[currentIndex]
        let engine = appState.engine

        engine.convertFile(at: item.url, to: format, quality: quality, resolution: resolution) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    items[currentIndex].status = .completed
                    items[currentIndex].outputURL = url
                case .failure(let error):
                    items[currentIndex].status = .failed
                    items[currentIndex].error = error.localizedDescription
                }
                completedCount += 1
                currentIndex += 1
                processNext()
            }
        }
    }
}

// MARK: - Batch Row

struct BatchRow: View {
    let index: Int
    let item: BatchItem

    var body: some View {
        HStack(spacing: 12) {
            Text("\(index)").font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(.textTertiary).frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.fileName).font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textPrimary).lineLimit(1)
                if let error = item.error {
                    Text(error).font(.system(size: 11)).foregroundColor(.red).lineLimit(1)
                }
            }

            Spacer()

            switch item.status {
            case .pending:
                Image(systemName: "circle").foregroundColor(.textTertiary).font(.system(size: 16))
            case .converting:
                SwiftUI.ProgressView().tint(.accent).scaleEffect(0.7)
            case .completed:
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green).font(.system(size: 18))
            case .failed:
                Image(systemName: "xmark.circle.fill").foregroundColor(.red).font(.system(size: 18))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.bgCard)
        .cornerRadius(10)
    }
}

