import Foundation

public enum TranscriptionDefaults {
    public static let model = "tiny"
}

public struct ModelChoice: Equatable, Sendable, Identifiable {
    public var name: String
    public var label: String
    public var detail: String

    public var id: String { name }

    public init(name: String, label: String, detail: String) {
        self.name = name
        self.label = label
        self.detail = detail
    }

    public static let catalog: [ModelChoice] = [
        ModelChoice(name: "tiny", label: "Tiny", detail: "Fastest. Fine for a first run."),
        ModelChoice(name: "base", label: "Base", detail: "A bit more accurate."),
        ModelChoice(name: "small", label: "Small", detail: "Better accuracy, slower."),
        ModelChoice(name: "medium", label: "Medium", detail: "Heavier. Use when you care about wording."),
    ]

    public static func label(for name: String) -> String {
        catalog.first(where: { $0.name == name })?.label ?? name
    }
}

public struct LanguageChoice: Equatable, Sendable, Identifiable {
    public var code: String
    public var label: String

    public var id: String { code }

    public init(code: String, label: String) {
        self.code = code
        self.label = label
    }

    public static let auto = LanguageChoice(code: "", label: "Auto-detect")

    public static let catalog: [LanguageChoice] = [
        auto,
        LanguageChoice(code: "en", label: "English"),
        LanguageChoice(code: "es", label: "Spanish"),
        LanguageChoice(code: "fr", label: "French"),
        LanguageChoice(code: "de", label: "German"),
        LanguageChoice(code: "pt", label: "Portuguese"),
        LanguageChoice(code: "it", label: "Italian"),
        LanguageChoice(code: "ja", label: "Japanese"),
        LanguageChoice(code: "zh", label: "Chinese"),
        LanguageChoice(code: "ko", label: "Korean"),
    ]
}
