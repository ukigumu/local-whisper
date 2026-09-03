#if os(macOS)
import AppKit
import LocalWhisperCore
import UniformTypeIdentifiers

enum FilePanels {
    static var mediaTypes: [UTType] {
        var types: [UTType] = [
            .mp3,
            .wav,
            .mpeg4Movie,
            .quickTimeMovie,
            .mpeg4Audio,
            .aiff,
        ]
        for ext in MediaClassifier.allExtensions.sorted() {
            if let type = UTType(filenameExtension: ext) {
                types.append(type)
            }
        }
        return types
    }

    static func pickMedia() -> URL? {
        let panel = NSOpenPanel()
        panel.title = "Choose audio or video"
        panel.prompt = "Transcribe"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = mediaTypes
        panel.allowsOtherFileTypes = false
        guard panel.runModal() == .OK else {
            return nil
        }
        return panel.url
    }

    @discardableResult
    static func saveText(suggestedName: String, contents: String) -> URL? {
        save(
            suggestedName: suggestedName,
            contents: contents,
            type: .plainText,
            title: "Save transcript"
        )
    }

    @discardableResult
    static func saveSRT(suggestedName: String, contents: String) -> URL? {
        let srt = UTType(filenameExtension: "srt") ?? .plainText
        return save(
            suggestedName: suggestedName,
            contents: contents,
            type: srt,
            title: "Save subtitles"
        )
    }

    private static func save(
        suggestedName: String,
        contents: String,
        type: UTType,
        title: String
    ) -> URL? {
        let panel = NSSavePanel()
        panel.title = title
        panel.canCreateDirectories = true
        panel.allowedContentTypes = [type]
        panel.nameFieldStringValue = suggestedName
        guard panel.runModal() == .OK, let url = panel.url else {
            return nil
        }
        do {
            try contents.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            NSAlert(error: error).runModal()
            return nil
        }
    }
}
#endif
