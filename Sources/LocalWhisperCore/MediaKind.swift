import Foundation

public enum MediaKind: String, Equatable, Sendable {
    case audio
    case video
}

public enum MediaClassifier {
    public static let audioExtensions: Set<String> = [
        "mp3", "wav", "m4a", "aac", "flac", "aiff", "aif", "caf", "wma",
    ]

    public static let videoExtensions: Set<String> = [
        "mp4", "mov", "m4v",
    ]

    public static func kind(for url: URL) -> MediaKind? {
        let ext = url.pathExtension.lowercased()
        if audioExtensions.contains(ext) {
            return .audio
        }
        if videoExtensions.contains(ext) {
            return .video
        }
        return nil
    }
}
