import SwiftUI

@main
struct LocalWhisperApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        Window("Local Whisper", id: "main") {
            RootView()
                .environment(model)
                .frame(minWidth: 680, minHeight: 540)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 760, height: 640)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open...") {
                    model.chooseFile()
                }
                .keyboardShortcut("o", modifiers: .command)
                .disabled(model.phase.isWorking)
            }
            CommandGroup(after: .pasteboard) {
                Button("Copy Transcript") {
                    model.copyTranscript()
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .disabled(!canCopy)
            }
            CommandGroup(after: .newItem) {
                Button("Save Transcript...") {
                    model.saveText()
                }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(!canCopy)
                Button("Save Subtitles...") {
                    model.saveSRT()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
                .disabled(!hasResult)
            }
        }
    }

    private var canCopy: Bool {
        if case .done(let done) = model.phase {
            return !done.transcript.displayText.isEmpty
        }
        return false
    }

    private var hasResult: Bool {
        if case .done = model.phase {
            return true
        }
        return false
    }
}
