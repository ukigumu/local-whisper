import Foundation
import LocalWhisperCore
import XCTest

final class ModelCacheTests: XCTestCase {
    func testFolderNameFromShortId() {
        XCTAssertEqual(ModelCache.folderName(for: "tiny"), "openai_whisper-tiny")
        XCTAssertEqual(ModelCache.folderName(for: "small"), "openai_whisper-small")
        XCTAssertEqual(ModelCache.folderName(for: "  base  "), "openai_whisper-base")
    }

    func testFolderNameKeepsWhisperKitNames() {
        XCTAssertEqual(
            ModelCache.folderName(for: "openai_whisper-tiny"),
            "openai_whisper-tiny"
        )
        XCTAssertEqual(
            ModelCache.folderName(for: "distil-whisper_distil-large-v3"),
            "distil-whisper_distil-large-v3"
        )
    }

    func testFolderNameFromRepoPath() {
        XCTAssertEqual(
            ModelCache.folderName(for: "argmaxinc/openai_whisper-tiny"),
            "openai_whisper-tiny"
        )
    }

    func testIsAvailableLooksForModelFiles() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("local-whisper-models-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }

        XCTAssertFalse(ModelCache.isAvailable(model: "tiny", downloadBase: root))

        let empty = ModelCache.folderURL(for: "tiny", downloadBase: root)
        try FileManager.default.createDirectory(at: empty, withIntermediateDirectories: true)
        XCTAssertFalse(ModelCache.isAvailable(model: "tiny", downloadBase: root))

        try "ok".write(to: empty.appendingPathComponent("config.json"), atomically: true, encoding: .utf8)
        XCTAssertTrue(ModelCache.isAvailable(model: "tiny", downloadBase: root))
    }
}
