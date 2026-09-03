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

    public static var allExtensions: Set<String> {
        audioExtensions.union(videoExtensions)
    }

    public static var audioList: String {
        audioExtensions.sorted().joined(separator: ", ")
    }

    public static var videoList: String {
        videoExtensions.sorted().joined(separator: ", ")
    }

    public static func kind(for url: URL) -> MediaKind? {
        kind(forExtension: url.pathExtension)
    }

    public static func kind(forExtension ext: String) -> MediaKind? {
        let normalized = ext.lowercased()
        if audioExtensions.contains(normalized) {
            return .audio
        }
        if videoExtensions.contains(normalized) {
            return .video
        }
        return nil
    }
}
