import XCTest
@testable import MediaMate

/// Unit tests for shared file utility functions.
final class FileUtilitiesTests: XCTestCase {
    
    func testFormatFileSizeReturnsUnknownForInvalidPath() {
        let result = FileUtilities.formatFileSize("/nonexistent/file.mp4")
        XCTAssertEqual(result, "Unknown")
    }
    
    func testFormatFileSizeFromURLDelegate() {
        let badURL = URL(fileURLWithPath: "/dev/null/undefined")
        let result = FileUtilities.formatFileSize(badURL)
        XCTAssertEqual(result, "Unknown")
    }
    
    func testIconForVideoExtension() {
        XCTAssertEqual(FileUtilities.iconForFileExtension("mp4"), "film")
        XCTAssertEqual(FileUtilities.iconForFileExtension("mov"), "film")
        XCTAssertEqual(FileUtilities.iconForFileExtension("avi"), "film")
        XCTAssertEqual(FileUtilities.iconForFileExtension("mkv"), "film")
    }
    
    func testIconForAudioExtension() {
        XCTAssertEqual(FileUtilities.iconForFileExtension("mp3"), "music.note")
        XCTAssertEqual(FileUtilities.iconForFileExtension("m4a"), "music.note")
        XCTAssertEqual(FileUtilities.iconForFileExtension("wav"), "music.note")
        XCTAssertEqual(FileUtilities.iconForFileExtension("aac"), "music.note")
    }
    
    func testIconForUnknownExtension() {
        XCTAssertEqual(FileUtilities.iconForFileExtension("txt"), "doc")
        XCTAssertEqual(FileUtilities.iconForFileExtension("pdf"), "doc")
    }
    
    func testIconIsCaseInsensitive() {
        XCTAssertEqual(FileUtilities.iconForFileExtension("MP4"), "film")
        XCTAssertEqual(FileUtilities.iconForFileExtension("MOV"), "film")
    }
}
