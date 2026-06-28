import Foundation
import AVFoundation
import ImageIO
import UniformTypeIdentifiers

public struct GIFExportEngine {

    public enum GIFError: LocalizedError {
        case noVideoTrack, exportFailed(String)
        public var errorDescription: String? {
            switch self {
            case .noVideoTrack: return "No video track found"
            case .exportFailed(let msg): return msg
            }
        }
    }

    /// Export a video file as animated GIF.
    /// - Parameters:
    ///   - sourceURL: Input video URL
    ///   - outputURL: Output GIF URL (should end in .gif)
    ///   - frameRate: Frames per second (default 15)
    ///   - maxWidth: Maximum width in pixels (nil = original)
    ///   - completion: Result callback on main thread
    public static func export(
        sourceURL: URL,
        outputURL: URL,
        frameRate: Int = 15,
        maxWidth: CGFloat? = nil,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let asset = AVURLAsset(url: sourceURL)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(.failure(GIFError.noVideoTrack))
            return
        }

        let duration = CMTimeGetSeconds(asset.duration)
        let totalFrames = Int(duration * Double(frameRate))
        let naturalSize = videoTrack.naturalSize
        let targetWidth = maxWidth ?? naturalSize.width
        let scale = targetWidth / naturalSize.width
        let targetSize = CGSize(width: targetWidth, height: naturalSize.height * scale)

        let reader: AVAssetReader
        do {
            reader = try AVAssetReader(asset: asset)
        } catch {
            completion(.failure(GIFError.exportFailed("Reader creation failed: \(error.localizedDescription)")))
            return
        }

        let readerOutput = AVAssetReaderTrackOutput(
            track: videoTrack,
            outputSettings: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB as OSType
            ]
        )
        guard reader.canAdd(readerOutput) else {
            completion(.failure(GIFError.exportFailed("Cannot add reader output")))
            return
        }
        reader.add(readerOutput)
        reader.startReading()

        let frameDuration = 1.0 / Double(frameRate)
        var sampledFrames: [CGImage] = []
        var lastSampleTime = CMTime.negativeInfinity

        while reader.status == .reading {
            guard let sample = readerOutput.copyNextSampleBuffer() else { break }
            let pts = CMSampleBufferGetPresentationTimeStamp(sample)
            if CMTimeCompare(pts, lastSampleTime) > 0 ||
                CMTimeCompare(lastSampleTime, CMTime.negativeInfinity) == 0 {
                if let imageBuffer = CMSampleBufferGetImageBuffer(sample) {
                    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
                    let context = CIContext(options: nil)
                    if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                        // Resize
                        let colorSpace = cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
                        if let context2 = CGContext(
                            data: nil,
                            width: Int(targetSize.width),
                            height: Int(targetSize.height),
                            bitsPerComponent: 8,
                            bytesPerRow: 0,
                            space: colorSpace,
                            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
                        ) {
                            context2.interpolationQuality = .high
                            context2.draw(cgImage, in: CGRect(origin: .zero, size: targetSize))
                            if let resized = context2.makeImage() {
                                sampledFrames.append(resized)
                            }
                        }
                    }
                }
                lastSampleTime = pts
            }

            // Skip frames to match target frameRate
            let nextTime = CMTimeAdd(lastSampleTime, CMTimeMake(value: 1, timescale: Int32(frameRate)))
            while reader.status == .reading {
                guard let nextSample = readerOutput.copyNextSampleBuffer() else { break }
                let nextPts = CMSampleBufferGetPresentationTimeStamp(nextSample)
                if CMTimeCompare(nextPts, nextTime) >= 0 {
                    lastSampleTime = nextPts
                    break
                }
            }
        }

        reader.cancelReading()

        guard !sampledFrames.isEmpty else {
            completion(.failure(GIFError.exportFailed("No frames extracted")))
            return
        }

        DispatchQueue.global(qos: .utility).async {
            guard let destination = CGImageDestinationCreateWithURL(
                outputURL as CFURL,
                UTType.gif.identifier as CFString,
                sampledFrames.count,
                nil
            ) else {
                DispatchQueue.main.async {
                    completion(.failure(GIFError.exportFailed("Cannot create GIF destination")))
                }
                return
            }

            let gifProperties: [String: Any] = [
                kCGImagePropertyGIFDictionary as String: [
                    kCGImagePropertyGIFLoopCount as String: 0 // loop forever
                ]
            ]
            CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)

            for frame in sampledFrames {
                let frameProperties: [String: Any] = [
                    kCGImagePropertyGIFDictionary as String: [
                        kCGImagePropertyGIFDelayTime as String: frameDuration
                    ]
                ]
                CGImageDestinationAddImage(destination, frame, frameProperties as CFDictionary)
            }

            let success = CGImageDestinationFinalize(destination)
            DispatchQueue.main.async {
                if success {
                    completion(.success(outputURL))
                } else {
                    completion(.failure(GIFError.exportFailed("GIF finalization failed")))
                }
            }
        }
    }
}
