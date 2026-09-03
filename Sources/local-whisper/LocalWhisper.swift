import ArgumentParser
import Foundation
import LocalWhisperCore

#if os(macOS)
import LocalWhisperMac
#endif

@main
struct LocalWhisper: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "local-whisper",
        abstract: "On-device Whisper transcription for local audio and video on macOS.",
        discussion: """
        Transcribes a local file with WhisperKit (Core ML, on-device).
        Video files have audio extracted with AVFoundation first.
        Writes .txt and .srt next to the input unless --output-dir is set.

        First run may download a Core ML model into the local cache.
        After that, inference stays on the Mac. Use --model-path and --no-download for a fully offline machine.

        The same pipeline powers the Local Whisper Mac app (open LocalWhisper.xcodeproj).
        """
    )

    @Argument(help: "Path to a local audio or video file.")
    var input: String

    @Option(
        name: [.short, .long],
        help: "Directory for .txt and .srt. Defaults to the input file directory."
    )
    var outputDir: String?

    @Option(name: .long, help: "WhisperKit model name. Default: tiny.")
    var model: String = TranscriptionDefaults.model

    @Option(name: .long, help: "Local CoreML model folder. Implies no download.")
    var modelPath: String?

    @Option(name: .long, help: "Language code such as en or es. Auto-detect if omitted.")
    var language: String?

    @Option(name: .long, help: "Output formats: txt, srt, or txt,srt. Default: txt,srt.")
    var formats: String = "txt,srt"

    @Flag(
        inversion: .prefixedNo,
        help: "Allow downloading a WhisperKit model on first use."
    )
    var download: Bool = true

    @Flag(name: [.short, .long], help: "Print progress on stderr.")
    var verbose: Bool = false

    @Flag(name: .long, help: "Print transcript text to stdout after writing files.")
    var printText: Bool = false

    mutating func run() async throws {
        #if os(macOS)
        try await runOnMac()
        #else
        throw LocalWhisperError.macOSRequired
        #endif
    }

    #if os(macOS)
    private func runOnMac() async throws {
        let inputURL = resolvedURL(input)
        let kind = try InputFile.classify(inputURL)
        let formats = try OutputFormats.parse(self.formats)
        let outputDirectory = outputDir.map(resolvedURL) ?? inputURL.deletingLastPathComponent()
        let modelFolder = modelPath.map(resolvedURL)?.path

        log("Input: \(inputURL.path) (\(kind.rawValue))")
        log("Output directory: \(outputDirectory.path)")
        if let modelFolder {
            log("Model folder: \(modelFolder)")
        } else {
            log("Model: \(model)")
        }

        let job = TranscriptionJob(
            inputURL: inputURL,
            model: model,
            modelFolder: modelFolder,
            language: language,
            download: download && modelFolder == nil,
            verbose: verbose
        )

        let transcript = try await TranscriptionPipeline.run(job) { progress in
            if verbose {
                switch progress.stage {
                case .transcribing:
                    break
                case .preparing, .loadingModel, .finished:
                    Stderr.write(progress.message)
                }
            }
        }
        let written = try OutputWriter.write(
            transcript: transcript,
            inputURL: inputURL,
            outputDirectory: outputDirectory,
            formats: formats
        )

        for path in written.paths {
            Stderr.write("Wrote \(path)")
        }

        if printText {
            print(transcript.displayText)
        }
    }
    #endif

    #if os(macOS)
    private func resolvedURL(_ path: String) -> URL {
        let expanded = NSString(string: path).expandingTildeInPath
        return URL(fileURLWithPath: expanded).standardizedFileURL
    }

    private func log(_ message: String) {
        guard verbose else {
            return
        }
        Stderr.write(message)
    }
    #endif
}
