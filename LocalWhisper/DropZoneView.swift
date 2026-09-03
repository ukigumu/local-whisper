import LocalWhisperCore
import SwiftUI

struct DropZoneView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let targeted = model.isDropTargeted

        VStack(spacing: 22) {
            Spacer()
            ZStack {
                Circle()
                    .fill((targeted ? Theme.amber : Theme.inkDim).opacity(0.08))
                    .frame(width: 96, height: 96)
                Circle()
                    .strokeBorder((targeted ? Theme.amber : Theme.inkDim).opacity(0.28), lineWidth: 1)
                    .frame(width: 96, height: 96)
                Image(systemName: targeted ? "arrow.down.circle" : "waveform")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(targeted ? Theme.amber : Theme.inkDim)
            }
            .reveal(0)

            VStack(spacing: 8) {
                Text(targeted ? "Drop to transcribe" : "Drop an audio or video file")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text("Audio: \(MediaClassifier.audioList). Video: \(MediaClassifier.videoList).")
                    .font(Theme.body)
                    .foregroundStyle(Theme.inkDim)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
            }
            .reveal(1)

            Button("Choose a file") {
                model.chooseFile()
            }
            .buttonStyle(AccentButtonStyle())
            .reveal(2)

            if !model.modelIsCached {
                Text("First run downloads the \(ModelChoice.label(for: model.modelName).lowercased()) model into the shared local cache. After that, this Mac stays offline.")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.inkFaint)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
                    .reveal(3)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Theme.pagePadding)
        .background(dropBackdrop(targeted: targeted))
    }

    private func dropBackdrop(targeted: Bool) -> some View {
        RoundedRectangle(cornerRadius: Theme.cornerLarge, style: .continuous)
            .strokeBorder(
                style: StrokeStyle(lineWidth: targeted ? 1.5 : 1, dash: [7, 6])
            )
            .foregroundStyle(targeted ? Theme.amber.opacity(0.8) : Theme.hairlineStrong)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerLarge, style: .continuous)
                    .fill(targeted ? Theme.amberSoft : Theme.bgInset)
            )
            .padding(20)
    }
}
