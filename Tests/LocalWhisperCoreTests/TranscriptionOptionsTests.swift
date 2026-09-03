import LocalWhisperCore
import XCTest

final class TranscriptionOptionsTests: XCTestCase {
    func testDefaultModelIsTiny() {
        XCTAssertEqual(TranscriptionDefaults.model, "tiny")
        XCTAssertEqual(ModelChoice.catalog.first?.name, "tiny")
    }

    func testModelLabels() {
        XCTAssertEqual(ModelChoice.label(for: "tiny"), "Tiny")
        XCTAssertEqual(ModelChoice.label(for: "custom-v1"), "custom-v1")
    }

    func testLanguageCatalogIncludesAutoAndEnglish() {
        XCTAssertEqual(LanguageChoice.catalog.first, .auto)
        XCTAssertTrue(LanguageChoice.catalog.contains(where: { $0.code == "en" }))
        XCTAssertTrue(LanguageChoice.catalog.contains(where: { $0.code == "es" }))
    }
}
