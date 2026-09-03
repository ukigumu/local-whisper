import Foundation

public struct WrittenOutputs: Equatable, Sendable {
    public var txtURL: URL?
    public var srtURL: URL?

    public init(txtURL: URL? = nil, srtURL: URL? = nil) {
        self.txtURL = txtURL
        self.srtURL = srtURL
    }

    public var paths: [String] {
        [txtURL, srtURL].compactMap { $0?.path }
    }
}

public enum OutputWriter {
    public static func write(
        transcript: Transcript,
        inputURL: URL,
        outputDirectory: URL,
        formats: OutputFormats
    ) throws -> WrittenOutputs {
        do {
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        } catch {
            throw LocalWhisperError.outputFailed(error.localizedDescription)
        }

        let stem = inputURL.deletingPathExtension().lastPathComponent
        var written = WrittenOutputs()

        if formats.txt {
            let url = outputDirectory.appendingPathComponent("\(stem).txt")
            do {
                try transcript.displayText.appending("\n").write(to: url, atomically: true, encoding: .utf8)
            } catch {
                throw LocalWhisperError.outputFailed(error.localizedDescription)
            }
            written.txtURL = url
        }

        if formats.srt {
            let url = outputDirectory.appendingPathComponent("\(stem).srt")
            do {
                try SRTFormatter.string(from: transcript).write(to: url, atomically: true, encoding: .utf8)
            } catch {
                throw LocalWhisperError.outputFailed(error.localizedDescription)
            }
            written.srtURL = url
        }

        return written
    }
}
