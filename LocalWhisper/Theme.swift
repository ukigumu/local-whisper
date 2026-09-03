import SwiftUI

/// Calm utility palette in the same family as What the cap: navy ground,
/// cream ink, one amber accent. Readable first. No keystroke chrome.
enum Theme {
    static let bg = Color(hex: 0x161824)
    static let bgRaised = Color(hex: 0x1C1F2E)
    static let bgInset = Color(hex: 0x111320)
    static let hairline = Color.white.opacity(0.06)
    static let hairlineStrong = Color.white.opacity(0.12)

    static let ink = Color(hex: 0xF7F3EA)
    static let inkDim = Color(hex: 0xA3A8BA)
    static let inkFaint = Color(hex: 0x646A80)

    static let amber = Color(hex: 0xECA626)
    static let amberSoft = Color(hex: 0xECA626).opacity(0.14)
    static let danger = Color(hex: 0xE5484D)
    static let calm = Color(hex: 0x6E9BD8)

    static let displayTitle = Font.system(size: 24, weight: .semibold)
    static let body = Font.system(size: 13, weight: .regular)
    static let caption = Font.system(size: 11, weight: .regular)
    static let mono = Font.system(size: 13, weight: .regular, design: .monospaced)

    static let cornerLarge: CGFloat = 16
    static let cornerSmall: CGFloat = 8
    static let pagePadding: CGFloat = 28

    static let spring = Animation.spring(response: 0.45, dampingFraction: 0.82)
    static let slowSpring = Animation.spring(response: 0.7, dampingFraction: 0.85)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
