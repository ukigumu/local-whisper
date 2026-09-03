#if os(macOS)
import Foundation
import LocalWhisperCore
import WhisperKit

public struct TranscribeRequest: Sendable {
    public var audioPath: String
    public var model: String
    public var modelFolder: String?
    public var downloadBase: URL
    public var download: Bool
    public var language: String?
    public var verbose: Bool

    public init(
        audioPath: String,
        model: String,
        modelFolder: String?,
        downloadBase: URL,
        download: Bool,
        language: String?,
        verbose: Bool
    ) {
        self.audioPath = audioPath
        self.model = model
        self.modelFolder = modelFolder
        self.downloadBase = downloadBase
        self.download = download
        self.language = language
        self.verbose = verbose
    }
}

public enum WhisperTranscriber {
    public static func transcribe(_ request: TranscribeRequest) async throws -> Transcript {
        if let modelFolder = request.modelFolder {
            var isDirectory: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: modelFolder, isDirectory: &isDirectory)
            guard exists, isDirectory.boolValue else {
                throw LocalWhisperError.modelNotFound(modelFolder)
            }
        }

        try FileManager.default.createDirectory(
            at: request.downloadBase,
            withIntermediateDirectories: true
        )

        let allowDownload = request.download && request.modelFolder == nil
        let config = WhisperKitConfig(
            model: request.modelFolder == nil ? request.model : nil,
            downloadBase: request.downloadBase,
            modelFolder: request.modelFolder,
            verbose: request.verbose,
            logLevel: request.verbose ? .debug : .info,
            download: allowDownload
        )

        let kit: WhisperKit
        do {
            kit = try await WhisperKit(config)
        } catch {
            if !allowDownload {
                throw LocalWhisperError.modelDownloadDisabled
            }
            throw LocalWhisperError.transcriptionFailed(error.localizedDescription)
        }

        let options = DecodingOptions(
            verbose: request.verbose,
            task: .transcribe,
            language: request.language,
            detectLanguage: request.language == nil,
            withoutTimestamps: false
        )

        let results: [TranscriptionResult]
        do {
            results = try await kit.transcribe(
                audioPath: request.audioPath,
                decodeOptions: options
            )
        } catch {
            throw LocalWhisperError.transcriptionFailed(error.localizedDescription)
        }

        let segments = results
            .flatMap(\.segments)
            .map { segment in
                Transcript.Segment(
                    start: TimeInterval(segment.start),
                    end: TimeInterval(segment.end),
                    text: segment.text.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            .filter { !$0.text.isEmpty }

        let joined = results
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return Transcript(
            text: joined,
            segments: segments,
            language: results.first?.language
        )
    }
}
#endif
