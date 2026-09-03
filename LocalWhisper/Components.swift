import SwiftUI

struct Wordmark: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text("LOCAL WHISPER")
                    .font(.system(size: 15, weight: .bold))
                    .kerning(1.4)
                    .foregroundStyle(Theme.ink)
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(Theme.amber)
                    .frame(width: 7, height: 7)
            }
            Text("On-device transcription")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Theme.inkFaint)
        }
    }
}

struct SectionLabel: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .kerning(1.4)
            .foregroundStyle(Theme.inkDim)
    }
}

struct Hairline: View {
    var body: some View {
        Rectangle()
            .fill(Theme.hairline)
            .frame(height: 1)
    }
}

struct Panel<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerLarge, style: .continuous)
                    .fill(Theme.bgRaised)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerLarge, style: .continuous)
                            .strokeBorder(Theme.hairline, lineWidth: 1)
                    )
            )
    }
}

struct AccentButtonStyle: ButtonStyle {
    var prominent = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(prominent ? Theme.bg : Theme.ink)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(prominent ? Theme.amber : Theme.bgRaised)
                    .overlay(
                        Capsule().strokeBorder(
                            prominent ? Color.clear : Theme.hairlineStrong,
                            lineWidth: 1
                        )
                    )
            )
            .opacity(configuration.isPressed ? 0.75 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct PrivacyRow: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.amber)
                .frame(width: 16)
            Text(text)
                .font(Theme.caption)
                .foregroundStyle(Theme.inkDim)
        }
    }
}

struct Reveal: ViewModifier {
    let index: Int
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 14)
            .onAppear {
                withAnimation(Theme.slowSpring.delay(Double(index) * 0.06)) {
                    shown = true
                }
            }
    }
}

extension View {
    func reveal(_ index: Int) -> some View {
        modifier(Reveal(index: index))
    }
}
