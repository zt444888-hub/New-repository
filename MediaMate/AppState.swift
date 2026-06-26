import Foundation
import SwiftData

class AppState: ObservableObject {
    @Published var recentItems: [ConversionItem] = []
    @Published var currentFile: URL?
    @Published var selectedFormat = "MP4"
    @Published var quality: Double = 2
    @Published var selectedResolution = "Original"
    @Published var conversionProgress: Double = 0
    @Published var convertedFile: URL?
    @Published var engine = ConversionEngine()

    @Published var originalFileSizeText: String = ""
    @Published var convertedFileSizeText: String = ""
    @Published var isTestMode = false
    @Published var originalFileName: String = ""

    /// Shared ModelContainer — also needs to be passed to `.modelContainer()` in the app scene.
    static let container: ModelContainer = {
        try! ModelContainer(for: ConversionItem.self)
    }()

    private let modelContext: ModelContext

    init() {
        modelContext = Self.container.mainContext
        loadFromStore()

        #if DEBUG
        if recentItems.isEmpty {
            loadDemoData()
        }
        #endif
    }

    // MARK: - Persistence

    private func loadFromStore() {
        let descriptor = FetchDescriptor<ConversionItem>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        recentItems = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func saveContext() {
        try? modelContext.save()
    }

    func addConversion(item: ConversionItem) {
        modelContext.insert(item)
        recentItems.insert(item, at: 0)
        saveContext()
    }

    func deleteConversion(_ item: ConversionItem) {
        modelContext.delete(item)
        recentItems.removeAll { $0.id == item.id }
        saveContext()
    }

    // MARK: - Demo Data (DEBUG only)

    func loadDemoData() {
        let items = [
            ConversionItem(
                fileName: "vacation_clip.mov",
                fromFormat: "MOV",
                toFormat: "MP4",
                originalSize: "128 MB",
                convertedSize: "48.3 MB",
                status: .completed,
                date: Date()
            ),
            ConversionItem(
                fileName: "recording.m4a",
                fromFormat: "M4A",
                toFormat: "M4A",
                originalSize: "4.2 MB",
                convertedSize: "1.8 MB",
                status: .completed,
                date: Date().addingTimeInterval(-86400)
            ),
            ConversionItem(
                fileName: "interview.mp4",
                fromFormat: "MP4",
                toFormat: "MOV",
                originalSize: "340 MB",
                convertedSize: nil,
                status: .failed,
                date: Date().addingTimeInterval(-172800)
            )
        ]
        items.forEach { modelContext.insert($0) }
        recentItems = items
        saveContext()
    }

    // MARK: - Conversion lifecycle

    func clearCurrentConversion() {
        currentFile = nil
        selectedFormat = "MP4"
        quality = 2
        selectedResolution = "Original"
        conversionProgress = 0
        convertedFile = nil

        originalFileSizeText = ""
        convertedFileSizeText = ""
        originalFileName = ""
        engine.progress = 0
        engine.isConverting = false
    }
}
