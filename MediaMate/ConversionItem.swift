import Foundation
import SwiftData

/// Raw-value backing for SwiftData storage.
enum ConversionStatus: String, Codable {
    case pending
    case converting
    case completed
    case failed
}

/// SwiftData‑backed model for a single conversion record.
@Model
final class ConversionItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var fileName: String
    var fromFormat: String
    var toFormat: String
    var originalSize: String
    var convertedSize: String?
    var statusRaw: String
    var date: Date

    /// Convenience computed property for `ConversionStatus`.
    var status: ConversionStatus {
        get { ConversionStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    init(
        fileName: String,
        fromFormat: String,
        toFormat: String,
        originalSize: String,
        convertedSize: String?,
        status: ConversionStatus,
        date: Date
    ) {
        self.id = UUID()
        self.fileName = fileName
        self.fromFormat = fromFormat
        self.toFormat = toFormat
        self.originalSize = originalSize
        self.convertedSize = convertedSize
        self.statusRaw = status.rawValue
        self.date = date
    }
}
