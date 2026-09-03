import Foundation
import LocalWhisperCore
import XCTest

final class OutputWriterTests: XCTestCase {
    func testWritesTxtAndSrt() throws {
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("local-whisper-tests-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: temp) }

        let input = URL(fileURLWithPath: "/tmp/lecture.mp3")
        let transcript = Transcript(
            text: "Hello from local-whisper",
            segments: [
                .init(start: 0, end: 1.5, text: "Hello from local-whisper"),
            ]
        )

        let written = try OutputWriter.write(
            transcript: transcript,
            inputURL: input,
            outputDirectory: temp,
            formats: .all
        )

        XCTAssertEqual(written.txtURL?.lastPathComponent, "lecture.txt")
        XCTAssertEqual(written.srtURL?.lastPathComponent, "lecture.srt")

        let txt = try String(contentsOf: written.txtURL!, encoding: .utf8)
        let srt = try String(contentsOf: written.srtURL!, encoding: .utf8)
        XCTAssertEqual(txt, "Hello from local-whisper\n")
        XCTAssertTrue(srt.contains("Hello from local-whisper"))
        XCTAssertTrue(srt.contains("00:00:00,000 --> 00:00:01,500"))
    }

    func testTxtOnly() throws {
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("local-whisper-tests-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: temp) }

        let written = try OutputWriter.write(
            transcript: Transcript(text: "only", segments: []),
            inputURL: URL(fileURLWithPath: "clip.mp4"),
            outputDirectory: temp,
            formats: OutputFormats(txt: true, srt: false)
        )

        XCTAssertNotNil(written.txtURL)
        XCTAssertNil(written.srtURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: temp.appendingPathComponent("clip.srt").path))
    }
}
