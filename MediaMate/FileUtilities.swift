import Foundation
import UIKit

/// Shared utilities for file handling throughout the app.
enum FileUtilities {
    
    /// Format a file size at the given path into a human-readable string (e.g. "24.5 MB").
    static func formatFileSize(_ path: String) -> String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            if let fileSize = attributes[.size] as? Int64 {
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useMB]
                formatter.countStyle = .file
                return formatter.string(fromByteCount: fileSize)
            }
        } catch {
            #if DEBUG
            print("Error getting file size: \(error)")
            #endif
        }
        return "Unknown"
    }
    
    /// Format file size at the given URL.
    static func formatFileSize(_ url: URL) -> String {
        formatFileSize(url.path)
    }
    
    /// Determine the SF Symbol icon name for a given file extension.
    static func iconForFileExtension(_ ext: String) -> String {
        switch ext.lowercased() {
        case "mov", "mp4", "avi", "mkv":
            return "film"
        case "m4a", "mp3", "wav", "aac":
            return "music.note"
        default:
            return "doc"
        }
    }
}

