import Foundation

public enum ModelCache {
    public static func defaultDownloadBase() -> URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        #if os(macOS)
        return home
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
            .appendingPathComponent("local-whisper")
            .appendingPathComponent("Models")
        #else
        return home
            .appendingPathComponent(".cache")
            .appendingPathComponent("local-whisper")
            .appendingPathComponent("models")
        #endif
    }

    /// WhisperKit folder name for a short model id such as `tiny` or `small`.
    public static func folderName(for model: String) -> String {
        let trimmed = model.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "openai_whisper-tiny"
        }
        if trimmed.contains("/") {
            return String(trimmed.split(separator: "/").last ?? "openai_whisper-tiny")
        }
        if trimmed.hasPrefix("openai_whisper-") || trimmed.hasPrefix("distil-whisper") {
            return trimmed
        }
        return "openai_whisper-\(trimmed)"
    }

    public static func folderURL(for model: String, downloadBase: URL = defaultDownloadBase()) -> URL {
        downloadBase.appendingPathComponent(folderName(for: model))
    }

    public static func isAvailable(model: String, downloadBase: URL = defaultDownloadBase()) -> Bool {
        let folder = folderURL(for: model, downloadBase: downloadBase)
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: folder.path, isDirectory: &isDirectory),
              isDirectory.boolValue
        else {
            return false
        }
        let contents = (try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []
        return contents.contains { name in
            name.hasSuffix(".mlmodelc") || name == "config.json" || name.hasSuffix(".mlpackage")
        }
    }
}
