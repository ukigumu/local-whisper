import Foundation

public enum LocalWhisperError: Error, LocalizedError, Equatable {
    case fileNotFound(String)
    case unsupportedMedia(String)
    case noAudioTrack(String)
    case audioExtractFailed(String)
    case modelNotFound(String)
    case modelDownloadDisabled
    case transcriptionFailed(String)
    case macOSRequired
    case invalidFormats(String)
    case outputFailed(String)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "Input file not found: \(path)"
        case .unsupportedMedia(let path):
            return "Unsupported media type: \(path). Use audio (mp3, wav, m4a, aac, flac, aiff, caf) or video (mp4, mov, m4v)."
        case .noAudioTrack(let path):
            return "No audio track in video: \(path)"
        case .audioExtractFailed(let message):
            return "Could not extract audio from video: \(message)"
        case .modelNotFound(let path):
            return "WhisperKit model folder not found: \(path)"
        case .modelDownloadDisabled:
            return "No local WhisperKit model is available and download is disabled. Pass --model-path or omit --no-download."
        case .transcriptionFailed(let message):
            return "Transcription failed: \(message)"
        case .macOSRequired:
            return "local-whisper needs macOS. WhisperKit and AVFoundation are Apple-only. On a Mac: make build for the CLI, or open LocalWhisper.xcodeproj for the app."
        case .invalidFormats(let value):
            return "Invalid --formats value: \(value). Use txt, srt, or txt,srt."
        case .outputFailed(let message):
            return "Could not write output: \(message)"
        }
    }
}
