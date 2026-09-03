import LocalWhisperCore
import XCTest

final class OutputFormatsTests: XCTestCase {
    func testParseBoth() throws {
        XCTAssertEqual(try OutputFormats.parse("txt,srt"), .all)
        XCTAssertEqual(try OutputFormats.parse("SRT, TXT"), .all)
    }

    func testParseSingle() throws {
        XCTAssertEqual(try OutputFormats.parse("txt"), OutputFormats(txt: true, srt: false))
        XCTAssertEqual(try OutputFormats.parse("srt"), OutputFormats(txt: false, srt: true))
    }

    func testRejectsUnknown() {
        XCTAssertThrowsError(try OutputFormats.parse("json")) { error in
            XCTAssertEqual(error as? LocalWhisperError, .invalidFormats("json"))
        }
    }

    func testRejectsEmpty() {
        XCTAssertThrowsError(try OutputFormats.parse("  "))
    }
}
