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
}
