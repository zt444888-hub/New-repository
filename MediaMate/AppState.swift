import Foundation

enum ConversionStatus {
    case pending
    case converting
    case completed
    case failed
}

struct ConversionItem: Identifiable {
    let id = UUID()
    let fileName: String
    let fromFormat: String
    let toFormat: String
    let originalSize: String
    let convertedSize: String?
    let status: ConversionStatus
    let date: Date
}

class AppState: ObservableObject {
    @Published var recentItems: [ConversionItem] = []
    @Published var currentFile: URL?
    @Published var selectedFormat = "MP4"
    @Published var quality: Double = 2
    @Published var selectedResolution = "Original"
    @Published var conversionProgress: Double = 0
    @Published var convertedFile: URL?
    @Published var engine = ConversionEngine()
    @Published var convertedFileURL: URL?
    @Published var originalFileSizeText: String = ""
    @Published var convertedFileSizeText: String = ""
    @Published var isTestMode = false
    @Published var originalFileName: String = ""
    
    init() {
        loadDemoData()
    }
    
    func loadDemoData() {
        recentItems = [
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
    }
    
    func addConversion(item: ConversionItem) {
        recentItems.insert(item, at: 0)
    }
    
    func clearCurrentConversion() {
        currentFile = nil
        selectedFormat = "MP4"
        quality = 2
        selectedResolution = "Original"
        conversionProgress = 0
        convertedFile = nil
        convertedFileURL = nil
        originalFileSizeText = ""
        convertedFileSizeText = ""
        originalFileName = ""
        engine.progress = 0
        engine.isConverting = false
    }
}
