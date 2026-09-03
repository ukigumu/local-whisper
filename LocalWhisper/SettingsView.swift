import LocalWhisperCore
import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(Theme.displayTitle)
                        .foregroundStyle(Theme.ink)
                    Text("Everything stays on this Mac")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.inkFaint)
                }

                Panel {
                    VStack(alignment: .leading, spacing: 18) {
                        SectionLabel("Transcription")
                        SettingRow(
                            title: "Model",
                            detail: model.modelIsCached
                                ? "Cached in the shared local-whisper folder. Offline."
                                : "First use downloads this Core ML model into the shared cache."
                        ) {
                            Picker("Model", selection: $model.modelName) {
                                ForEach(ModelChoice.catalog) { choice in
                                    Text(choice.label).tag(choice.name)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 140)
                            .disabled(model.phase.isWorking)
                        }
                        if let choice = ModelChoice.catalog.first(where: { $0.name == model.modelName }) {
                            Text(choice.detail)
                                .font(Theme.caption)
                                .foregroundStyle(Theme.inkFaint)
                        }
                        Hairline()
                        SettingRow(
                            title: "Language",
                            detail: "Auto-detect unless you force a language code."
                        ) {
                            Picker("Language", selection: $model.languageCode) {
                                ForEach(LanguageChoice.catalog) { choice in
                                    Text(choice.label).tag(choice.code)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 140)
                            .disabled(model.phase.isWorking)
                        }
                    }
                }

                Panel {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionLabel("Privacy")
                        PrivacyRow(
                            symbol: "internaldrive",
                            text: "Audio and video stay on this Mac. There is no cloud transcription API."
                        )
                        PrivacyRow(
                            symbol: "cpu",
                            text: "WhisperKit runs on-device with Core ML. The CLI and this app share one pipeline."
                        )
                        PrivacyRow(
                            symbol: "arrow.down.circle",
                            text: "The first run may download a model into ~/Library/Application Support/local-whisper/Models. Later runs reuse that cache."
                        )
                        PrivacyRow(
                            symbol: "eye",
                            text: "This is a normal windowed utility. Nothing is sent anywhere after the optional model download."
                        )
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 560, alignment: .leading)
        }
        .frame(width: 560, height: 460)
        .background(Theme.bg)
    }
}

struct SettingRow<Accessory: View>: View {
    let title: String
    let detail: String
    @ViewBuilder var accessory: Accessory

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.ink)
                Text(detail)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.inkDim)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            accessory
        }
    }
}
