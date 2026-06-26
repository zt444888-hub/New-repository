import Foundation

/// A conversion preset optimized for a specific platform or use case.
public struct Preset: Identifiable, Codable, Hashable {
    public let id: UUID
    public let name: String
    public let icon: String
    public let category: Category
    public let format: String
    public let resolution: String
    public let quality: Double
    public let description: String

    public enum Category: String, Codable, CaseIterable {
        case social, messaging, audio, archive
    }

    public init(
        id: UUID = UUID(),
        name: String, icon: String, category: Category,
        format: String, resolution: String, quality: Double,
        description: String
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.category = category
        self.format = format
        self.resolution = resolution
        self.quality = quality
        self.description = description
    }

    public static let all: [Preset] = [
        Preset(name: "Instagram Reel", icon: "camera.viewfinder", category: .social,
               format: "MP4", resolution: "1080p", quality: 2,
               description: "Optimized for Instagram Stories & Reels"),
        Preset(name: "TikTok", icon: "music.note.tv", category: .social,
               format: "MP4", resolution: "1080p", quality: 1,
               description: "Best quality-size balance for TikTok"),
        Preset(name: "YouTube", icon: "play.rectangle", category: .social,
               format: "MP4", resolution: "1080p", quality: 2,
               description: "High quality upload ready for YouTube"),
        Preset(name: "Twitter / X", icon: "message", category: .social,
               format: "MP4", resolution: "720p", quality: 1,
               description: "Twitter/X friendly size and format"),
        Preset(name: "WhatsApp", icon: "bubble.left", category: .messaging,
               format: "MP4", resolution: "720p", quality: 1,
               description: "Compressed for fast WhatsApp sharing"),
        Preset(name: "Telegram", icon: "paperplane", category: .messaging,
               format: "MP4", resolution: "1080p", quality: 1,
               description: "Balanced preset for Telegram"),
        Preset(name: "Email Attachment", icon: "envelope", category: .messaging,
               format: "MP4", resolution: "480p", quality: 0,
               description: "Small file size for email sending"),
        Preset(name: "Music Archive", icon: "hifispeaker", category: .audio,
               format: "M4A", resolution: "Original", quality: 3,
               description: "Lossless audio preservation"),
        Preset(name: "Podcast Ready", icon: "mic", category: .audio,
               format: "MP3", resolution: "Original", quality: 1,
               description: "Standard podcast audio format"),
        Preset(name: "Original Quality", icon: "archivebox", category: .archive,
               format: "MOV", resolution: "Original", quality: 3,
               description: "Highest quality archival copy"),
    ]
}
