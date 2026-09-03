import Foundation

public enum InputFile {
    public static func classify(_ url: URL) throws -> MediaKind {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw LocalWhisperError.fileNotFound(url.path)
        }
        guard let kind = MediaClassifier.kind(for: url) else {
            throw LocalWhisperError.unsupportedMedia(url.path)
        }
        return kind
    }
}
