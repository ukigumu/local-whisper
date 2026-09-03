import LocalWhisperCore
import SwiftUI

struct WorkingView: View {
    @Environment(AppModel.self) private var model
    let state: WorkingState

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            fileHeader(name: state.fileName, detail: state.message)

            ProgressView()
                .progressViewStyle(.linear)
                .tint(Theme.amber)
                .controlSize(.small)

            if state.partialText.isEmpty {
                Text("WhisperKit is running on this Mac. Nothing is uploaded.")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.inkFaint)
            } else {
                ScrollView {
                    Text(state.partialText)
                        .font(Theme.mono)
                        .foregroundStyle(Theme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
            }

            HStack {
                Button("Stop") {
                    model.cancel()
                }
                .buttonStyle(AccentButtonStyle(prominent: false))
                Spacer()
            }
        }
        .padding(Theme.pagePadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func fileHeader(name: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.ink)
            Text(detail)
                .font(Theme.caption)
                .foregroundStyle(Theme.inkDim)
        }
    }
}

struct DoneView: View {
    @Environment(AppModel.self) private var model
    let state: DoneState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(state.fileName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text(subtitle)
                        .font(Theme.caption)
                        .foregroundStyle(Theme.inkDim)
                }
                Spacer()
                Button("New file") {
                    model.reset()
                }
                .buttonStyle(AccentButtonStyle(prominent: false))
            }

            ScrollView {
                Text(state.transcript.displayText.isEmpty ? "(No speech detected)" : state.transcript.displayText)
                    .font(Theme.mono)
                    .foregroundStyle(state.transcript.displayText.isEmpty ? Theme.inkFaint : Theme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .padding(16)
            }
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerLarge, style: .continuous)
                    .fill(Theme.bgInset)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerLarge, style: .continuous)
                            .strokeBorder(Theme.hairline, lineWidth: 1)
                    )
            )

            HStack(spacing: 10) {
                Button(model.copied ? "Copied" : "Copy") {
                    model.copyTranscript()
                }
                .buttonStyle(AccentButtonStyle())
                .disabled(state.transcript.displayText.isEmpty)

                Button("Save .txt") {
                    model.saveText()
                }
                .buttonStyle(AccentButtonStyle(prominent: false))
                .disabled(state.transcript.displayText.isEmpty)

                Button("Save .srt") {
                    model.saveSRT()
                }
                .buttonStyle(AccentButtonStyle(prominent: false))

                Spacer()
            }

            if let path = model.lastExportPath {
                Text("Saved \(path)")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.inkFaint)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .padding(Theme.pagePadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var subtitle: String {
        let language = state.transcript.language.map { "Language \($0)" } ?? "Language auto"
        let cues = state.transcript.segments.count
        if cues == 0 {
            return "\(language). No timed cues."
        }
        return "\(language). \(cues) cue\(cues == 1 ? "" : "s") ready for .srt."
    }
}

struct FailedView: View {
    @Environment(AppModel.self) private var model
    let state: FailedState

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Theme.danger.opacity(0.08))
                    .frame(width: 88, height: 88)
                Circle()
                    .strokeBorder(Theme.danger.opacity(0.25), lineWidth: 1)
                    .frame(width: 88, height: 88)
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(Theme.danger)
            }
            Text(state.fileName ?? "Could not transcribe")
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(Theme.ink)
            Text(state.message)
                .font(Theme.body)
                .foregroundStyle(Theme.inkDim)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
            HStack(spacing: 10) {
                Button("Choose a file") {
                    model.chooseFile()
                }
                .buttonStyle(AccentButtonStyle())
                Button("Back") {
                    model.reset()
                }
                .buttonStyle(AccentButtonStyle(prominent: false))
            }
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Theme.pagePadding)
    }
}
