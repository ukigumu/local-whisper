#if os(macOS)
import Foundation
import LocalWhisperCore

public struct TranscriptionJob: Sendable {
    public var inputURL: URL
    public var model: String
    public var modelFolder: String?
    public var language: String?
    public var download: Bool
    public var verbose: Bool

    public init(
        inputURL: URL,
        model: String = TranscriptionDefaults.model,
        modelFolder: String? = nil,
        language: String? = nil,
        download: Bool = true,
        verbose: Bool = false
    ) {
        self.inputURL = inputURL
        self.model = model
        self.modelFolder = modelFolder
        self.language = language
        self.download = download
        self.verbose = verbose
    }
}

public enum TranscriptionStage: String, Sendable, Equatable {
    case preparing
    case loadingModel
    case transcribing
    case finished
}

public struct JobProgress: Sendable, Equatable {
    public var stage: TranscriptionStage
    public var message: String
    public var partialText: String

    public init(stage: TranscriptionStage, message: String, partialText: String = "") {
        self.stage = stage
        self.message = message
        self.partialText = partialText
    }
}

/// Shared WhisperKit job used by the CLI and the Mac app.
public enum TranscriptionPipeline {
    public static func run(
        _ job: TranscriptionJob,
        onProgress: (@Sendable (JobProgress) -> Void)? = nil
    ) async throws -> Transcript {
        try Task.checkCancellation()
        let kind = try InputFile.classify(job.inputURL)

        let preparingMessage = kind == .video
            ? "Extracting audio from video..."
            : "Preparing audio..."
        onProgress?(JobProgress(stage: .preparing, message: preparingMessage))

        let prepared = try await AudioExtractor.prepareAudioURL(for: job.inputURL, kind: kind)
        defer { prepared.cleanup() }

        try Task.checkCancellation()

        onProgress?(JobProgress(stage: .loadingModel, message: loadingMessage(for: job)))

        let request = TranscribeRequest(
            audioPath: prepared.url.path,
            model: job.model,
            modelFolder: job.modelFolder,
            downloadBase: ModelCache.defaultDownloadBase(),
            download: job.download && job.modelFolder == nil,
            language: job.language,
            verbose: job.verbose
        )

        let transcript = try await WhisperTranscriber.transcribe(request) { partial in
            if Task.isCancelled {
                return false
            }
            onProgress?(
                JobProgress(
                    stage: .transcribing,
                    message: "Transcribing...",
                    partialText: partial
                )
            )
            return true
        }

        try Task.checkCancellation()
        onProgress?(
            JobProgress(
                stage: .finished,
                message: "Done",
                partialText: transcript.displayText
            )
        )
        return transcript
    }

    private static func loadingMessage(for job: TranscriptionJob) -> String {
        if job.modelFolder != nil {
            return "Loading local model..."
        }
        if ModelCache.isAvailable(model: job.model) {
            return "Loading \(job.model) model..."
        }
        if job.download {
            return "Downloading \(job.model) model (first run)..."
        }
        return "Loading \(job.model) model..."
    }
}
#endif
