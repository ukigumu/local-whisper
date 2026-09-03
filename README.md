# local-whisper

On-device Whisper transcription for local audio and video on Mac.

Uses [WhisperKit](https://github.com/argmaxinc/argmax-oss-swift) (Core ML) for inference. No cloud transcription API. Video audio is extracted with AVFoundation. The same pipeline powers a Swift CLI and a one-job SwiftUI app.

## Requirements

- macOS 14 or later
- Xcode 16+ (app) or Xcode 15.4+ / Swift 5.10+ (CLI)
- A local audio or video file

Full transcription will not compile or run on Linux. WhisperKit, Core ML, AVFoundation, and the SwiftUI app are Apple-only.

## Mac app

A normal window, not a menu bar extra. Drop a file or pick one, watch progress, then copy or save.

```bash
git clone https://github.com/ukigumu/local-whisper.git
cd local-whisper
open LocalWhisper.xcodeproj
```

Press Run in Xcode. Or from the repo root:

```bash
make open
make app
make run-app
```

`make app` needs `xcodebuild` (a Mac with Xcode). Linux cannot build the `.app`. That is expected.

### App flow

1. Drop an `mp3` or `mp4` (or choose a file). Other CLI formats work too: `wav`, `m4a`, `aac`, `flac`, `aiff`, `caf`, `mov`, `m4v`.
2. First run may download a Core ML model into the shared cache (see Models below). Later runs stay offline.
3. Progress shows the current stage. Partial text appears when WhisperKit emits it.
4. Read the transcript in the scrollable view.
5. Copy, Save `.txt`, or Save `.srt`.

Settings (header pickers or the slider button):

- Model: `tiny` (default), `base`, `small`, `medium`
- Language: auto-detect, or force a code such as `en` / `es`

Audio never leaves this Mac. There is no cloud transcription API. The app is not sandboxed so it can read the file you picked and share the CLI model cache.

## Build the CLI (macOS)

```bash
git clone https://github.com/ukigumu/local-whisper.git
cd local-whisper
make build
```

The binary lands at `.build/release/local-whisper`.

## Transcribe (CLI)

```bash
make run FILE=talk.mp3
make run FILE=clip.mp4 ARGS='--verbose'
.build/release/local-whisper lecture.m4a --output-dir ./out
```

Default output (same directory as the input):

- `talk.txt`
- `talk.srt`

Supported audio: `mp3`, `wav`, `m4a`, `aac`, `flac`, `aiff`, `caf`.

Supported video: `mp4`, `mov`, `m4v`. Video is remuxed to a temporary `.m4a` with `AVAssetExportSession` before WhisperKit runs.

## Models (offline after first cache)

WhisperKit runs entirely on the Mac. The first run (CLI or app) may download a Core ML model from Hugging Face into:

```text
~/Library/Application Support/local-whisper/Models
```

Default model is `tiny` so a first clone can finish quickly. Larger names work when you want better accuracy:

```bash
.build/release/local-whisper talk.mp3 --model base
.build/release/local-whisper talk.mp3 --model small
```

Fully offline machine (no download):

```bash
.build/release/local-whisper talk.mp3 --model-path /path/to/openai_whisper-tiny --no-download
```

`--model-path` must point at a WhisperKit Core ML model folder (the directory that contains the compiled `.mlmodelc` files).

## CLI

```text
local-whisper <input> [--output-dir DIR] [--model NAME] [--model-path PATH]
              [--language CODE] [--formats txt,srt] [--no-download]
              [--verbose] [--print-text]
```

| Flag | Meaning |
| --- | --- |
| `--output-dir`, `-o` | Where to write `.txt` / `.srt`. Default: input file directory |
| `--model` | WhisperKit model name. Default: `tiny` |
| `--model-path` | Local Core ML folder. Skips download |
| `--language` | Force a language (`en`, `es`, ...). Default: auto-detect |
| `--formats` | `txt`, `srt`, or `txt,srt` |
| `--no-download` | Fail if a local model is not already available |
| `--verbose`, `-v` | Progress on stderr |
| `--print-text` | Also print the transcript on stdout |

Existing output files are overwritten.

## Makefile

| Target | What it does |
| --- | --- |
| `make build` | `swift build -c release --product local-whisper` |
| `make run FILE=...` | Build if needed and transcribe |
| `make open` | `open LocalWhisper.xcodeproj` |
| `make app` | Debug `xcodebuild` of the Mac app into `build/` |
| `make run-app` | Build the app and launch it |
| `make test` | Portable unit tests (SRT, formats, file writes, input checks) |
| `make clean` | Remove `.build` and `build/` |
| `make help` | List targets |

`CONFIG=debug` selects a debug CLI build.

## Repo layout

```text
Sources/LocalWhisperCore   Portable types, SRT, formats, model cache paths
Sources/LocalWhisperMac    WhisperKit + AVFoundation pipeline (CLI and app)
Sources/local-whisper      CLI entry
LocalWhisper/              SwiftUI Mac app
LocalWhisper.xcodeproj     App target; links the local Swift package
```

`TranscriptionPipeline` is the shared job: classify the file, extract audio from video, load or download the model, transcribe, return a `Transcript`.

## Linux / CI

This repo is Mac-ready. A Linux Swift toolchain can still typecheck the portable layer:

- `LocalWhisperCore` (SRT timestamps, format parsing, output paths, input checks) builds without Apple frameworks
- `swift test` runs those unit tests if Swift is installed
- `swift run local-whisper` exits with a clear macOS-required error
- `Package.swift` only pulls WhisperKit when the host is macOS, so Linux resolve does not need Core ML
- `make app` and `open LocalWhisper.xcodeproj` need a Mac. Linux CI cannot build the SwiftUI app

Do not expect a Linux binary that transcribes audio, and do not expect Linux CI to compile the `.app`.

## License

MIT. See `LICENSE`.

WhisperKit is a separate project from Argmax (MIT). Model weights follow their own licenses (typically the OpenAI Whisper model terms plus Argmax Core ML packaging).
