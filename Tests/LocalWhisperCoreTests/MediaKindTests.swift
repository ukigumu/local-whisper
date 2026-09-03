import Foundation
import LocalWhisperCore
import XCTest

final class MediaKindTests: XCTestCase {
    func testAudioExtensions() {
        XCTAssertEqual(MediaClassifier.kind(for: URL(fileURLWithPath: "/tmp/talk.mp3")), .audio)
        XCTAssertEqual(MediaClassifier.kind(for: URL(fileURLWithPath: "/tmp/talk.WAV")), .audio)
        XCTAssertEqual(MediaClassifier.kind(for: URL(fileURLWithPath: "/tmp/talk.m4a")), .audio)
        XCTAssertEqual(MediaClassifier.kind(for: URL(fileURLWithPath: "/tmp/talk.flac")), .audio)
    }

    func testVideoExtensions() {
        XCTAssertEqual(MediaClassifier.kind(for: URL(fileURLWithPath: "/tmp/clip.mp4")), .video)
        XCTAssertEqual(MediaClassifier.kind(for: URL(fileURLWithPath: "/tmp/clip.MOV")), .video)
        XCTAssertEqual(MediaClassifier.kind(for: URL(fileURLWithPath: "/tmp/clip.m4v")), .video)
    }

    func testUnsupported() {
        XCTAssertNil(MediaClassifier.kind(for: URL(fileURLWithPath: "/tmp/notes.txt")))
        XCTAssertNil(MediaClassifier.kind(for: URL(fileURLWithPath: "/tmp/clip.mkv")))
    }
}
