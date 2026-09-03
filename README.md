# local-whisper

macOS Swift CLI for on-device Whisper transcription of local audio and video.

Uses [WhisperKit](https://github.com/argmaxinc/argmax-oss-swift) (Core ML) for inference. No cloud transcription API. Video audio is extracted with AVFoundation. Writes `.txt` and `.srt`.

## Requirements

- macOS 14 or later
- Xcode 15.4+ or a matching Swift 5.10+ toolchain (Apple Silicon recommended)
- A local audio or video file

Full transcription will not compile or run on Linux. WhisperKit, Core ML, and AVFoundation are Apple frameworks.

## Build (macOS)

```bash
git clone https://github.com/ukigumu/local-whisper.git
cd local-whisper
make build
```

The binary lands at `.build/release/local-whisper`.

## Transcribe

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

WhisperKit runs entirely on the Mac. The first run may download a Core ML model from Hugging Face into:

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
| `make test` | Portable unit tests (SRT, formats, file writes) |
| `make clean` | Remove `.build` |
| `make help` | List targets |

`CONFIG=debug` selects a debug build.

## Linux / CI

This repo is Mac-ready. A Linux Swift toolchain can still typecheck the portable layer:

- `LocalWhisperCore` (SRT timestamps, format parsing, output paths) builds without Apple frameworks
- `swift test` runs those unit tests if Swift is installed
- `swift run local-whisper` exits with a clear macOS-required error
- `Package.swift` only pulls WhisperKit when the host is macOS, so Linux resolve does not need Core ML

Do not expect a Linux binary that transcribes audio.

## License

MIT. See `LICENSE`.

WhisperKit is a separate project from Argmax (MIT). Model weights follow their own licenses (typically the OpenAI Whisper model terms plus Argmax Core ML packaging).
