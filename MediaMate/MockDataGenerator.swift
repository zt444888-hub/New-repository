import Foundation
import UIKit

class MockDataGenerator {
    static let shared = MockDataGenerator()
    
    private let fileManager = FileManager.default
    private var mockFiles: [URL] = []
    private var hasAttemptedCreation = false
    
    private init() {
        print("📦 MockDataGenerator singleton initialized")
    }
    
    func setupMockFiles() {
        print("\n========================================")
        print("🔧 setupMockFiles() called")
        print("  hasAttemptedCreation: \(hasAttemptedCreation)")
        print("  mockFiles count BEFORE: \(mockFiles.count)")
        
        if hasAttemptedCreation && !mockFiles.isEmpty {
            print("  → SKIPPING: Already attempted and files exist")
            print("========================================\n")
            return
        }
        
        hasAttemptedCreation = true
        mockFiles.removeAll()
        
        let videoFormats = ["mov", "mp4"]
        let audioFormats = ["m4a", "mp3", "wav"]
        
        print("\n🚀 Starting Mock File Generation")
        print("📂 Temporary directory: \(NSTemporaryDirectory())")
        
        var successCount = 0
        
        for i in 0..<3 {
            let format = videoFormats.randomElement() ?? "mp4"
            print("\n📹 Attempting video file \(i+1) (\(format))...")
            
            if let videoUrl = createMockVideoFile(format: format) {
                mockFiles.append(videoUrl)
                successCount += 1
                print("  ✅ SUCCESS: \(videoUrl.lastPathComponent)")
            } else {
                print("  ❌ FAILED: Could not create video file")
            }
        }
        
        for i in 0..<2 {
            let format = audioFormats.randomElement() ?? "m4a"
            print("\n🎵 Attempting audio file \(i+1) (\(format))...")
            
            if let audioUrl = createMockAudioFile(format: format) {
                mockFiles.append(audioUrl)
                successCount += 1
                print("  ✅ SUCCESS: \(audioUrl.lastPathComponent)")
            } else {
                print("  ❌ FAILED: Could not create audio file")
            }
        }
        
        print("\n📊 Mock File Generation Complete")
        print("  Total files created: \(mockFiles.count)")
        
        if mockFiles.isEmpty {
            print("\n⚠️ WARNING: No mock files were created!")
            print("  → Attempting fallback creation...")
            createFallbackFiles()
        }
        
        print("\n  mockFiles count AFTER: \(mockFiles.count)")
        for (index, file) in mockFiles.enumerated() {
            print("    \(index+1). \(file.lastPathComponent)")
        }
        print("========================================\n")
    }
    
    private func createFallbackFiles() {
        print("\n🔄 Creating fallback mock files...")
        
        let fallbackDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("MediaMateMock")
        print("  Fallback directory: \(fallbackDir.path)")
        
        do {
            try fileManager.createDirectory(at: fallbackDir, withIntermediateDirectories: true)
            print("  ✅ Created fallback directory")
            
            let testVideoUrl = fallbackDir.appendingPathComponent("test_video.mp4")
            let testAudioUrl = fallbackDir.appendingPathComponent("test_audio.mp3")
            
            let smallData = Data(repeating: 0x00, count: 1024 * 1024 * 2)
            
            try smallData.write(to: testVideoUrl)
            print("  ✅ Created test_video.mp4")
            
            try smallData.write(to: testAudioUrl)
            print("  ✅ Created test_audio.mp3")
            
            mockFiles.append(testVideoUrl)
            mockFiles.append(testAudioUrl)
            
            print("  ✅ Fallback files created successfully")
            
        } catch {
            print("  ❌ Failed to create fallback files:")
            print("    Error: \(error.localizedDescription)")
            print("    Full error: \(error)")
        }
    }
    
    func getMockFiles() -> [URL] {
        print("📥 getMockFiles() called")
        setupMockFiles()
        return mockFiles
    }
    
    func getRandomMockFile() -> URL? {
        print("\n🎲 getRandomMockFile() called")
        setupMockFiles()
        
        print("  Current mockFiles count: \(mockFiles.count)")
        
        guard !mockFiles.isEmpty else {
            print("  ❌ ERROR: No mock files available!")
            return nil
        }
        
        let selected = mockFiles.randomElement()
        print("  ✅ Selected file: \(selected?.lastPathComponent ?? "nil")")
        return selected
    }
    
    private func createMockVideoFile(format: String) -> URL? {
        let fileName = "mock_video_\(UUID().uuidString.prefix(8)).\(format)"
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileUrl = tempDir.appendingPathComponent(fileName)
        
        print("    Path: \(fileUrl.path)")
        
        do {
            let videoData = generateMockVideoData(sizeMB: Double.random(in: 2...5))
            print("    Generated data: \(videoData.count) bytes")
            
            try videoData.write(to: fileUrl)
            print("    ✅ File written successfully")
            
            return fileUrl
        } catch {
            print("    ❌ Error writing file:")
            print("      - Description: \(error.localizedDescription)")
            print("      - Full error: \(error)")
            return nil
        }
    }
    
    private func createMockAudioFile(format: String) -> URL? {
        let fileName = "mock_audio_\(UUID().uuidString.prefix(8)).\(format)"
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileUrl = tempDir.appendingPathComponent(fileName)
        
        print("    Path: \(fileUrl.path)")
        
        do {
            let audioData = generateMockAudioData(sizeMB: Double.random(in: 1...3))
            print("    Generated data: \(audioData.count) bytes")
            
            try audioData.write(to: fileUrl)
            print("    ✅ File written successfully")
            
            return fileUrl
        } catch {
            print("    ❌ Error writing file:")
            print("      - Description: \(error.localizedDescription)")
            print("      - Full error: \(error)")
            return nil
        }
    }
    
    private func generateMockVideoData(sizeMB: Double) -> Data {
        let sizeBytes = Int(sizeMB * 1024 * 1024)
        var data = Data(capacity: sizeBytes)
        
        let header = createVideoHeader()
        data.append(header)
        
        let remainingBytes = sizeBytes - header.count
        let chunkSize = 1024 * 1024
        let pattern: [UInt8] = [0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x01, 0x01]
        
        var bytesWritten = 0
        while bytesWritten < remainingBytes {
            let chunkSizeToWrite = min(chunkSize, remainingBytes - bytesWritten)
            let repeats = chunkSizeToWrite / pattern.count
            let remainder = chunkSizeToWrite % pattern.count
            
            for _ in 0..<repeats {
                data.append(contentsOf: pattern)
            }
            data.append(contentsOf: pattern[0..<remainder])
            
            bytesWritten += chunkSizeToWrite
        }
        
        return data
    }
    
    private func generateMockAudioData(sizeMB: Double) -> Data {
        let sizeBytes = Int(sizeMB * 1024 * 1024)
        var data = Data(capacity: sizeBytes)
        
        let header = createAudioHeader()
        data.append(header)
        
        let remainingBytes = sizeBytes - header.count
        let chunkSize = 1024 * 1024
        
        var bytesWritten = 0
        while bytesWritten < remainingBytes {
            let chunkSizeToWrite = min(chunkSize, remainingBytes - bytesWritten)
            let randomData = Data((0..<chunkSizeToWrite).map { _ in UInt8.random(in: 0...255) })
            data.append(randomData)
            bytesWritten += chunkSizeToWrite
        }
        
        return data
    }
    
    private func createVideoHeader() -> Data {
        let headerString = """
            ftypmp42
            mp42isom
            free
            mdat
        """
        return Data(headerString.utf8)
    }
    
    private func createAudioHeader() -> Data {
        let headerString = """
            ftypM4A 
            M4A isom
            free
            mdat
        """
        return Data(headerString.utf8)
    }
}

extension MockDataGenerator {
    func simulatePhotoPickerSelection() -> URL? {
        print("\n📷 simulatePhotoPickerSelection() called")
        return getRandomMockFile()
    }
    
    func simulateDocumentPickerSelection() -> URL? {
        print("\n📁 simulateDocumentPickerSelection() called")
        return getRandomMockFile()
    }
    
    func formatFileSize(_ url: URL) -> String {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? Int64 {
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useMB]
                formatter.countStyle = .file
                return formatter.string(fromByteCount: fileSize)
            }
        } catch {
            print("Error getting file size: \(error)")
        }
        return "Unknown"
    }
    
    func getFileInfo(_ url: URL) -> (name: String, size: String, type: String) {
        let name = url.lastPathComponent
        let size = formatFileSize(url)
        let type = url.pathExtension.uppercased()
        
        return (name, size, type)
    }
}