import Foundation
import LocalWhisperCore
import Observation
#if os(macOS)
import AppKit
import LocalWhisperMac
#endif

enum AppPhase: Equatable {
    case idle
    case working(WorkingState)
    case done(DoneState)
    case failed(FailedState)

    var isWorking: Bool {
        if case .working = self { return true }
        return false
    }
}

struct WorkingState: Equatable {
    var fileName: String
    var message: String
    var partialText: String
}

struct DoneState: Equatable {
    var fileName: String
    var inputURL: URL
    var transcript: Transcript
}

struct FailedState: Equatable {
    var fileName: String?
    var message: String
}

@MainActor
@Observable
final class AppModel {
    var phase: AppPhase = .idle
    var copied = false
    var showSettings = false
    var isDropTargeted = false
    var lastExportPath: String?

    var modelName: String {
        didSet { UserDefaults.standard.set(modelName, forKey: Keys.model) }
    }

    var languageCode: String {
        didSet { UserDefaults.standard.set(languageCode, forKey: Keys.language) }
    }

    var modelIsCached: Bool {
        ModelCache.isAvailable(model: modelName)
    }

    @ObservationIgnored
    private var work: Task<Void, Never>?
    @ObservationIgnored
    private var copyReset: Task<Void, Never>?

    private enum Keys {
        static let model = "localwhisper.model"
        static let language = "localwhisper.language"
    }

    init() {
        let storedModel = UserDefaults.standard.string(forKey: Keys.model)
        if let storedModel, ModelChoice.catalog.contains(where: { $0.name == storedModel }) {
            modelName = storedModel
        } else {
            modelName = TranscriptionDefaults.model
        }
        languageCode = UserDefaults.standard.string(forKey: Keys.language) ?? ""
    }

    func chooseFile() {
        #if os(macOS)
        guard let url = FilePanels.pickMedia() else {
            return
        }
        transcribe(url: url)
        #endif
    }

    func ingest(urls: [URL]) {
        if let match = urls.first(where: { MediaClassifier.kind(for: $0) != nil }) {
            transcribe(url: match)
            return
        }
        if let first = urls.first {
            phase = .failed(
                FailedState(
                    fileName: first.lastPathComponent,
                    message: LocalWhisperError.unsupportedMedia(first.path).errorDescription
                        ?? "Unsupported file."
                )
            )
        }
    }

    func transcribe(url: URL) {
        work?.cancel()
        copied = false
        lastExportPath = nil
        work = Task { await run(url: url) }
    }

    func cancel() {
        work?.cancel()
        work = nil
        phase = .idle
    }

    func reset() {
        work?.cancel()
        work = nil
        copied = false
        lastExportPath = nil
        phase = .idle
    }

    func copyTranscript() {
        guard case .done(let done) = phase else {
            return
        }
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(done.transcript.displayText, forType: .string)
        #endif
        copied = true
        copyReset?.cancel()
        copyReset = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            copied = false
        }
    }

    func saveText() {
        guard case .done(let done) = phase else {
            return
        }
        #if os(macOS)
        let stem = done.inputURL.deletingPathExtension().lastPathComponent
        if let url = FilePanels.saveText(
            suggestedName: "\(stem).txt",
            contents: done.transcript.displayText + "\n"
        ) {
            lastExportPath = url.path
        }
        #endif
    }

    func saveSRT() {
        guard case .done(let done) = phase else {
            return
        }
        #if os(macOS)
        let stem = done.inputURL.deletingPathExtension().lastPathComponent
        let body = SRTFormatter.string(from: done.transcript)
        if let url = FilePanels.saveSRT(suggestedName: "\(stem).srt", contents: body) {
            lastExportPath = url.path
        }
        #endif
    }

    private func run(url: URL) async {
        let fileName = url.lastPathComponent
        phase = .working(
            WorkingState(
                fileName: fileName,
                message: "Starting...",
                partialText: ""
            )
        )

        #if os(macOS)
        let job = TranscriptionJob(
            inputURL: url,
            model: modelName,
            language: languageCode.isEmpty ? nil : languageCode,
            download: true,
            verbose: false
        )

        do {
            let transcript = try await TranscriptionPipeline.run(job) { progress in
                Task { @MainActor in
                    if case .working(var working) = self.phase, working.fileName == fileName {
                        working.message = progress.message
                        if !progress.partialText.isEmpty {
                            working.partialText = progress.partialText
                        }
                        self.phase = .working(working)
                    }
                }
            }

            guard !Task.isCancelled else {
                return
            }
            phase = .done(DoneState(fileName: fileName, inputURL: url, transcript: transcript))
        } catch is CancellationError {
            if case .working = phase {
                phase = .idle
            }
        } catch {
            guard !Task.isCancelled else {
                return
            }
            phase = .failed(
                FailedState(
                    fileName: fileName,
                    message: (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                )
            )
        }
        #else
        phase = .failed(
            FailedState(
                fileName: fileName,
                message: LocalWhisperError.macOSRequired.errorDescription ?? "macOS required."
            )
        )
        #endif
    }
}
