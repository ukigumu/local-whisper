import Foundation
import LocalWhisperCore
import XCTest

final class InputFileTests: XCTestCase {
    func testMissingFile() {
        let url = URL(fileURLWithPath: "/tmp/local-whisper-missing-\(UUID().uuidString).mp3")
        XCTAssertThrowsError(try InputFile.classify(url)) { error in
            XCTAssertEqual(error as? LocalWhisperError, .fileNotFound(url.path))
        }
    }

    func testUnsupportedExistingFile() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("local-whisper-\(UUID().uuidString).txt")
        try "notes".write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertThrowsError(try InputFile.classify(url)) { error in
            XCTAssertEqual(error as? LocalWhisperError, .unsupportedMedia(url.path))
        }
    }

    func testSupportedExistingFile() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("local-whisper-\(UUID().uuidString).mp3")
        try Data().write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertEqual(try InputFile.classify(url), .audio)
    }
}
