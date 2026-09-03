import Foundation
import LocalWhisperCore
import XCTest

final class SRTFormatterTests: XCTestCase {
    func testTimestampRounding() {
        XCTAssertEqual(SRTFormatter.timestamp(0), "00:00:00,000")
        XCTAssertEqual(SRTFormatter.timestamp(1.5), "00:00:01,500")
        XCTAssertEqual(SRTFormatter.timestamp(61.234), "00:01:01,234")
        XCTAssertEqual(SRTFormatter.timestamp(3723.456), "01:02:03,456")
        XCTAssertEqual(SRTFormatter.timestamp(-1), "00:00:00,000")
    }

    func testEmptyTranscript() {
        let transcript = Transcript(text: "", segments: [])
        XCTAssertEqual(SRTFormatter.string(from: transcript), "")
    }

    func testSkipsBlankSegmentsAndRenumbers() {
        let transcript = Transcript(
            text: "Hello world",
            segments: [
                .init(start: 0, end: 1.25, text: "Hello"),
                .init(start: 1.25, end: 2, text: "   "),
                .init(start: 2, end: 3.5, text: "world"),
            ]
        )

        let expected = """
        1
        00:00:00,000 --> 00:00:01,250
        Hello

        2
        00:00:02,000 --> 00:00:03,500
        world
        """ + "\n"

        XCTAssertEqual(SRTFormatter.string(from: transcript), expected)
    }

    func testZeroLengthSegmentGetsOneMillisecond() {
        let transcript = Transcript(
            text: "x",
            segments: [.init(start: 1.0, end: 1.0, text: "x")]
        )
        XCTAssertTrue(SRTFormatter.string(from: transcript).contains("00:00:01,000 --> 00:00:01,001"))
    }
}
