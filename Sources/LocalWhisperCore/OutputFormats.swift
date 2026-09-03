import Foundation

public struct OutputFormats: Equatable, Sendable {
    public var txt: Bool
    public var srt: Bool

    public init(txt: Bool, srt: Bool) {
        self.txt = txt
        self.srt = srt
    }

    public static let all = OutputFormats(txt: true, srt: true)

    public static func parse(_ raw: String) throws -> OutputFormats {
        let tokens = raw
            .split(whereSeparator: { $0 == "," || $0 == " " || $0 == ";" })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }

        guard !tokens.isEmpty else {
            throw LocalWhisperError.invalidFormats(raw)
        }

        var txt = false
        var srt = false
        for token in tokens {
            switch token {
            case "txt", "text":
                txt = true
            case "srt":
                srt = true
            default:
                throw LocalWhisperError.invalidFormats(raw)
            }
        }

        return OutputFormats(txt: txt, srt: srt)
    }
}
