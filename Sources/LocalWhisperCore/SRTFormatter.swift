import Foundation

public enum SRTFormatter {
    public static func string(from transcript: Transcript) -> String {
        let cues = transcript.segments.compactMap { segment -> (TimeInterval, TimeInterval, String)? in
            let text = segment.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else {
                return nil
            }
            let start = max(0, segment.start)
            let end = max(segment.end, start + 0.001)
            return (start, end, text)
        }

        if cues.isEmpty {
            return ""
        }

        var blocks: [String] = []
        blocks.reserveCapacity(cues.count)
        for (index, cue) in cues.enumerated() {
            let block = [
                "\(index + 1)",
                "\(timestamp(cue.0)) --> \(timestamp(cue.1))",
                cue.2,
            ].joined(separator: "\n")
            blocks.append(block)
        }
        return blocks.joined(separator: "\n\n") + "\n"
    }

    public static func timestamp(_ seconds: TimeInterval) -> String {
        let totalMilliseconds = max(0, Int((seconds * 1000).rounded()))
        let hours = totalMilliseconds / 3_600_000
        let minutes = (totalMilliseconds % 3_600_000) / 60_000
        let secs = (totalMilliseconds % 60_000) / 1000
        let millis = totalMilliseconds % 1000
        return String(format: "%02d:%02d:%02d,%03d", hours, minutes, secs, millis)
    }
}
