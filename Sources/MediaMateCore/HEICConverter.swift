import Foundation
import UIKit

public struct HEICConverter {

    public enum HEICError: LocalizedError {
        case notHEIC, conversionFailed
        public var errorDescription: String? {
            switch self {
            case .notHEIC: return "File is not a HEIC image"
            case .conversionFailed: return "HEIC conversion failed"
            }
        }
    }

    /// Convert a HEIC image file to JPEG.
    /// - Parameters:
    ///   - sourceURL: HEIC file URL
    ///   - outputURL: Output JPEG URL
    ///   - quality: Compression quality 0.0–1.0
    ///   - completion: Result callback
    public static func convertToJPEG(
        sourceURL: URL,
        outputURL: URL,
        quality: CGFloat = 0.85,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .utility).async {
            guard let image = UIImage(contentsOfFile: sourceURL.path) else {
                DispatchQueue.main.async { completion(.failure(HEICError.conversionFailed)) }
                return
            }
            guard let data = image.jpegData(compressionQuality: quality) else {
                DispatchQueue.main.async { completion(.failure(HEICError.conversionFailed)) }
                return
            }
            do {
                try data.write(to: outputURL)
                DispatchQueue.main.async { completion(.success(outputURL)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    /// Convert a HEIC image file to PNG.
    public static func convertToPNG(
        sourceURL: URL,
        outputURL: URL,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .utility).async {
            guard let image = UIImage(contentsOfFile: sourceURL.path) else {
                DispatchQueue.main.async { completion(.failure(HEICError.conversionFailed)) }
                return
            }
            guard let data = image.pngData() else {
                DispatchQueue.main.async { completion(.failure(HEICError.conversionFailed)) }
                return
            }
            do {
                try data.write(to: outputURL)
                DispatchQueue.main.async { completion(.success(outputURL)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
}
