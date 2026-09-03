import LocalWhisperCore
import XCTest

final class LocalWhisperErrorTests: XCTestCase {
    func testMacRequiredMessage() {
        let message = LocalWhisperError.macOSRequired.errorDescription ?? ""
        XCTAssertTrue(message.contains("macOS"))
        XCTAssertTrue(message.contains("make build"))
    }

    func testUnsupportedMentionsContainers() {
        let message = LocalWhisperError.unsupportedMedia("clip.mkv").errorDescription ?? ""
        XCTAssertTrue(message.contains("mp3"))
        XCTAssertTrue(message.contains("mp4"))
    }
}
