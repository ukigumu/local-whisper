import Foundation

public struct Transcript: Equatable, Sendable {
    public struct Segment: Equatable, Sendable {
        public var start: TimeInterval
        public var end: TimeInterval
        public var text: String

        public init(start: TimeInterval, end: TimeInterval, text: String) {
            self.start = start
            self.end = end
            self.text = text
        }
    }

    public var text: String
    public var segments: [Segment]
    public var language: String?

    public init(text: String, segments: [Segment], language: String? = nil) {
        self.text = text
        self.segments = segments
        self.language = language
    }

    public var displayText: String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            return trimmed
        }
        return segments
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
