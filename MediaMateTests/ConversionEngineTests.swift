import XCTest
@testable import MediaMate

/// Unit tests for the conversion engine state management.
///
/// These tests verify state transitions without triggering actual
/// AVFoundation operations, which require simulator runtime.
final class ConversionEngineTests: XCTestCase {
    
    var engine: ConversionEngine!
    
    override func setUp() {
        super.setUp()
        engine = ConversionEngine()
    }
    
    override func tearDown() {
        engine = nil
        super.tearDown()
    }
    
    func testInitialStateIsIdle() {
        XCTAssertEqual(engine.conversionState, .idle)
        XCTAssertFalse(engine.isConverting)
        XCTAssertEqual(engine.progress, 0)
    }
    
    func testRejectsConcurrentConversion() {
        // Simulate an already-running conversion
        engine.isConverting = true
        engine.conversionState = .converting
        
        let dummyURL = URL(fileURLWithPath: "/dev/null")
        let expectation = XCTestExpectation(description: "Completion called")
        
        engine.convertFile(at: dummyURL, to: "MP4", quality: 2, resolution: "Original") { result in
            if case .failure(let error) = result {
                XCTAssertEqual((error as NSError).code, -1)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCancelResetsToIdle() {
        engine.isConverting = true
        engine.conversionState = .converting
        engine.progress = 0.5
        
        engine.cancel()
        
        XCTAssertEqual(engine.conversionState, .idle)
        XCTAssertFalse(engine.isConverting)
        XCTAssertEqual(engine.progress, 0)
    }
}
