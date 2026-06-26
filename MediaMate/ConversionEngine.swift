﻿import AVFoundation
import UIKit
import Foundation

class ConversionEngine: NSObject, ObservableObject {
    @Published var progress: Double = 0
    @Published var isConverting = false

    enum ConversionState: Equatable {
        case idle
        case converting
        case completed
        case failed
    }
    @Published var conversionState: ConversionState = .idle

    private var exportSession: AVAssetExportSession?
    private var reader: AVAssetReader?
    private var writer: AVAssetWriter?
    private var completion: ((Result<URL, Error>) -> Void)?
    private let audioFormats: Set<String> = [""M4A"", ""MP3"", ""WAV""]
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    @Published var lastError: String?

    func convertFile(at sourceURL: URL, to format: String, quality: Double, resolution: String, completion: @escaping (Result<URL, Error>) -> Void) {
        // Keep conversion alive when app goes to background
        lastError = nil
                backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "MediaMate Conversion") { [weak self] in
            self?.cancel()
        }

        guard !isConverting else {
            completion(.failure(NSError(domain: ""MediaMate"", code: -1, userInfo: [NSLocalizedDescriptionKey: ""Conversion in progress""])))
            lastError = "Conversion already in progress"
                    endBackgroundTask()
            return
        }

        isConverting = true
        conversionState = .converting
        progress = 0
        self.completion = completion

        // Wrap completion to end background task automatically
        let wrappedCompletion: (Result<URL, Error>) -> Void = { [weak self] result in
            completion(result)
            if case .failure(let error) = result {
                self?.lastError = (error as NSError).localizedDescription
            }
            self?.endBackgroundTask()
        }

        let outputURL = outputURLFor(sourceURL, format: format)

        if audioFormats.contains(format) {
            convertAudioOnly(sourceURL: sourceURL, to: format, outputURL: outputURL, completion: wrappedCompletion)
        } else {
            convertVideoExport(sourceURL: sourceURL, to: format, outputURL: outputURL, quality: quality, resolution: resolution, completion: wrappedCompletion)
        }
    }

    private func convertVideoExport(sourceURL: URL, to format: String, outputURL: URL, quality: Double, resolution: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let asset = AVAsset(url: sourceURL)
        let preset = avAssetExportPreset(for: quality, resolution: resolution)

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: preset) else {
            isConverting = false
            conversionState = .failed
            completion(.failure(NSError(domain: ""MediaMate"", code: -2, userInfo: [NSLocalizedDescriptionKey: ""Failed to create export session""])))
            return
        }

        self.exportSession = exportSession
        exportSession.outputURL = outputURL
        exportSession.outputFileType = avVideoFileType(for: format)
        exportSession.shouldOptimizeForNetworkUse = true

        if #available(iOS 16.0, *) {
        if #available(iOS 16.0, *) {
            exportSession.progressHandler = { [weak self] progress in
                DispatchQueue.main.async {
                    self?.progress = progress
                }
            }
        } else {
            // Fallback for iOS < 16: poll export progress via Timer
            let pollingTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] timer in
                DispatchQueue.main.async {
                    guard let self = self, let session = self.exportSession else { return }
                    self.progress = session.progress
                    if session.status == .completed || session.status == .failed || session.status == .cancelled {
                        timer.invalidate()
                    }
                }
            }
            RunLoop.main.add(pollingTimer, forMode: .common)
        }


        exportSession.exportAsynchronously { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isConverting = false

                switch exportSession.status {
                case .completed:
                    completion(.success(outputURL))
                case .cancelled:
                    completion(.failure(NSError(domain: ""MediaMate"", code: -4, userInfo: [NSLocalizedDescriptionKey: ""Cancelled""])))
                case .failed:
                    let detail = exportSession.error?.localizedDescription ?? ""Unknown error""
                    completion(.failure(NSError(domain: ""MediaMate"", code: -3, userInfo: [NSLocalizedDescriptionKey: detail])))
                default:
                    completion(.failure(NSError(domain: ""MediaMate"", code: -3, userInfo: [NSLocalizedDescriptionKey: ""Export failed""])))
                }
            }
        }
    }

    private func convertAudioOnly(sourceURL: URL, to format: String, outputURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let asset = AVAsset(url: sourceURL)

        guard let audioTrack = asset.tracks(withMediaType: .audio).first {
            isConverting = false
            conversionState = .failed
            completion(.failure(NSError(domain: ""MediaMate"", code: -5, userInfo: [NSLocalizedDescriptionKey: ""No audio track found in file""])))
            return
        }

        do {
            reader = try AVAssetReader(asset: asset)
        } catch {
            isConverting = false
            conversionState = .failed
            completion(.failure(NSError(domain: ""MediaMate"", code: -6, userInfo: [NSLocalizedDescriptionKey: ""Failed to create reader: \(error.localizedDescription)""])))
            return
        }

        guard let reader = reader else { return }

        let readerOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: [
            AVFormatIDKey: kAudioFormatLinearPCM
        ])

        guard reader.canAdd(readerOutput) else {
            isConverting = false
            completion(.failure(NSError(domain: ""MediaMate"", code: -7, userInfo: [NSLocalizedDescriptionKey: ""Cannot read audio track""])))
            return
        }
        reader.add(readerOutput)

        let outputFileType: AVFileType
        let audioSettings: [String: Any]

        if format == ""WAV"" {
            outputFileType = .wav
            audioSettings = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: false
            ]
        } else {
            // M4A / MP3 fallback: use AAC in M4A container
            // iOS has no built-in MP3 encoder; AAC is superior
            outputFileType = .m4a
            audioSettings = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderBitRateKey: 128000
            ]
        }

        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: outputFileType)
        } catch {
            isConverting = false
            conversionState = .failed
            completion(.failure(NSError(domain: ""MediaMate"", code: -8, userInfo: [NSLocalizedDescriptionKey: ""Failed to create writer: \(error.localizedDescription)""])))
            return
        }

        guard let writer = writer else { return }

        let writerInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        writerInput.expectsMediaDataInRealTime = false

        guard writer.canAdd(writerInput) else {
            isConverting = false
            completion(.failure(NSError(domain: ""MediaMate"", code: -9, userInfo: [NSLocalizedDescriptionKey: ""Cannot add audio writer""])))
            return
        }
        writer.add(writerInput)

        writer.startWriting()
        reader.startReading()
        writer.startSession(atSourceTime: .zero)

        let totalDuration = audioTrack.timeRange.duration
        let totalSeconds = CMTimeGetSeconds(totalDuration)

        writerInput.requestMediaDataWhenReady(on: DispatchQueue(label: ""com.mediamate.audio"")) { [weak self] in
            guard let self = self, let reader = self.reader, let writer = self.writer else { return }

            while writerInput.isReadyForMoreMediaData {
                guard let buffer = readerOutput.copyNextSampleBuffer() else {
                    writerInput.markAsFinished()

                    if reader.status == .completed {
                        writer.finishWriting { [weak self] in
                            DispatchQueue.main.async {
                                self?.isConverting = false
                                self?.conversionState = .completed
                                self?.progress = 1.0
                                completion(.success(outputURL))
                            }
                        }
                    } else {
                        writer.cancelWriting()
                        reader.cancelReading()
                        DispatchQueue.main.async {
                            self.isConverting = false
                            self.conversionState = .failed
                            completion(.failure(NSError(domain: "MediaMate", code: -10, userInfo: [NSLocalizedDescriptionKey: ""Audio read failed""])))
                        }
                    }
                    return
                }

                let pts = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(buffer))
                if totalSeconds > 0 {
                    DispatchQueue.main.async {
                        self.progress = min(pts / totalSeconds, 0.99)
                    }
                }

                writerInput.append(buffer)
            }
        }
    }

    func cancel() {
        exportSession?.cancelExport()
        reader?.cancelReading()
        writer?.cancelWriting()
        endBackgroundTask()
        conversionState = .idle
        progress = 0
    }

    private func avAssetExportPreset(for quality: Double, resolution: String) -> String {
        let qualityPresets: [Double: String] = [
            0: AVAssetExportPresetLowQuality,
            1: AVAssetExportPresetMediumQuality,
            2: AVAssetExportPresetHighestQuality,
            3: AVAssetExportPresetPassthrough
        ]

        let resolutionPresets: [String: String] = [
            ""1080p"": AVAssetExportPreset1920x1080,
            ""720p"": AVAssetExportPreset1280x720,
            ""480p"": AVAssetExportPreset640x480
        ]

        if resolution != ""Original"", let preset = resolutionPresets[resolution] {
            return preset
        }

        return qualityPresets[quality] ?? AVAssetExportPresetHighestQuality
    }

    private func avVideoFileType(for format: String) -> AVFileType {
        let types: [String: AVFileType] = [
            ""MP4"": .mp4,
            ""MOV"": .mov
        ]
        return types[format] ?? .mp4
    }

    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }

    private func outputURLFor(_ sourceURL: URL, format: String) -> URL {
        let fileManager = FileManager.default
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = sourceURL.deletingPathExtension().lastPathComponent

        // For MP3, use .m4a extension since there is no MP3 encoder on iOS
        let ext = format == ""MP3"" ? ""m4a"" : format.lowercased()
        let outputFileName = ""\(fileName)_converted.\(ext)""
        return documentsDir.appendingPathComponent(outputFileName)
    }
}