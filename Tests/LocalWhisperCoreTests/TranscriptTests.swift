import LocalWhisperCore
import XCTest

final class TranscriptTests: XCTestCase {
    func testDisplayTextPrefersJoinedText() {
        let transcript = Transcript(
            text: "Hello world",
            segments: [.init(start: 0, end: 1, text: "Hello")]
        )
        XCTAssertEqual(transcript.displayText, "Hello world")
    }

    func testDisplayTextFallsBackToSegments() {
        let transcript = Transcript(
            text: "  ",
            segments: [
                .init(start: 0, end: 1, text: "Hello"),
                .init(start: 1, end: 2, text: "world"),
            ]
        )
        XCTAssertEqual(transcript.displayText, "Hello world")
    }
}
