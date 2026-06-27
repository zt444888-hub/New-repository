import AVFoundation
import UIKit

/// Generates thumbnail images from video files using AVFoundation.
enum ThumbnailGenerator {
    
    /// Generate a thumbnail at the midpoint of a video.
    /// - Parameters:
    ///   - url: URL of the video file
    ///   - maxSize: Maximum dimension for the thumbnail (default 200px)
    /// - Returns: UIImage thumbnail, or nil if generation fails
    static func thumbnail(for url: URL, maxSize: CGFloat = 200) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: maxSize, height: maxSize)
        
        let duration = CMTimeGetSeconds(asset.duration)
        guard duration.isFinite, duration > 0 else { return nil }
        
        let time = CMTime(seconds: duration * 0.3, preferredTimescale: 600)
        
        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            /* error handled */
            return nil
        }
    }
}

