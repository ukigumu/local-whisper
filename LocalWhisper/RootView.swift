import LocalWhisperCore
import SwiftUI
import UniformTypeIdentifiers

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            header
            Hairline()
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Hairline()
            footer
        }
        .background(Theme.bg)
        .background(WindowBackgroundDrag())
        .preferredColorScheme(.dark)
        .sheet(isPresented: $model.showSettings) {
            SettingsView()
                .environment(model)
        }
        .onDrop(of: [.fileURL], isTargeted: dropBinding, perform: { providers in
            handleDrop(providers)
        })
    }

    private var dropBinding: Binding<Bool>? {
        if model.phase.isWorking {
            return nil
        }
        return Binding(
            get: { model.isDropTargeted },
            set: { model.isDropTargeted = $0 }
        )
    }

    private var header: some View {
        @Bindable var model = model
        return HStack(alignment: .center, spacing: 16) {
            Wordmark()
            Spacer()
            HStack(spacing: 10) {
                Picker("Model", selection: $model.modelName) {
                    ForEach(ModelChoice.catalog) { choice in
                        Text(choice.label).tag(choice.name)
                    }
                }
                .labelsHidden()
                .frame(width: 110)
                .disabled(model.phase.isWorking)

                Picker("Language", selection: $model.languageCode) {
                    ForEach(LanguageChoice.catalog) { choice in
                        Text(choice.label).tag(choice.code)
                    }
                }
                .labelsHidden()
                .frame(width: 130)
                .disabled(model.phase.isWorking)
            }
            .controlSize(.small)

            Button {
                model.showSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.inkDim)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Theme.bgRaised))
            }
            .buttonStyle(.plain)
            .help("Settings")
            .disabled(model.phase.isWorking)
        }
        .padding(.horizontal, Theme.pagePadding)
        .padding(.vertical, 16)
    }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .idle:
            DropZoneView()
        case .working(let state):
            WorkingView(state: state)
        case .done(let state):
            DoneView(state: state)
        case .failed(let state):
            FailedView(state: state)
        }
    }

    private var footer: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Theme.amber)
                .frame(width: 6, height: 6)
            Text("Local only. WhisperKit on this Mac. No cloud API.")
                .font(Theme.caption)
                .foregroundStyle(Theme.inkFaint)
            Spacer()
        }
        .padding(.horizontal, Theme.pagePadding)
        .padding(.vertical, 12)
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard !model.phase.isWorking else {
            return false
        }
        let matches = providers.filter { $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }
        guard !matches.isEmpty else {
            return false
        }
        for provider in matches {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                let url: URL?
                if let value = item as? URL {
                    url = value
                } else if let data = item as? Data {
                    url = URL(dataRepresentation: data, relativeTo: nil)
                } else {
                    url = nil
                }
                guard let url else {
                    return
                }
                Task { @MainActor in
                    model.ingest(urls: [url])
                }
            }
        }
        return true
    }
}

#if os(macOS)
import AppKit

private struct WindowBackgroundDrag: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            view.window?.isMovableByWindowBackground = true
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        nsView.window?.isMovableByWindowBackground = true
    }
}
#else
private struct WindowBackgroundDrag: View {
    var body: some View { Color.clear }
}
#endif
