#if os(macOS)
import AVFoundation
import Foundation
import LocalWhisperCore

public enum AudioExtractor {
    public static func prepareAudioURL(for input: URL, kind: MediaKind) async throws -> PreparedAudio {
        switch kind {
        case .audio:
            return PreparedAudio(url: input, isTemporary: false)
        case .video:
            let extracted = try await extractAudio(from: input)
            return PreparedAudio(url: extracted, isTemporary: true)
        }
    }

    public static func extractAudio(from videoURL: URL) async throws -> URL {
        let asset = AVURLAsset(url: videoURL)
        let tracks: [AVAssetTrack]
        do {
            tracks = try await asset.loadTracks(withMediaType: .audio)
        } catch {
            throw LocalWhisperError.audioExtractFailed(error.localizedDescription)
        }

        guard !tracks.isEmpty else {
            throw LocalWhisperError.noAudioTrack(videoURL.path)
        }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("local-whisper-\(UUID().uuidString).m4a")

        guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw LocalWhisperError.audioExtractFailed("AVAssetExportSession could not be created.")
        }

        if #available(macOS 15.0, *) {
            do {
                try await session.export(to: tempURL, as: .m4a)
                return tempURL
            } catch {
                throw LocalWhisperError.audioExtractFailed(error.localizedDescription)
            }
        }

        try await exportLegacy(session: session, to: tempURL)
        return tempURL
    }

    private static func exportLegacy(session: AVAssetExportSession, to outputURL: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            session.outputURL = outputURL
            session.outputFileType = .m4a
            session.exportAsynchronously {
                switch session.status {
                case .completed:
                    continuation.resume()
                case .cancelled:
                    continuation.resume(throwing: LocalWhisperError.audioExtractFailed("Export cancelled."))
                default:
                    let message = session.error?.localizedDescription ?? "Export failed."
                    continuation.resume(throwing: LocalWhisperError.audioExtractFailed(message))
                }
            }
        }
    }
}

public struct PreparedAudio: Sendable {
    public var url: URL
    public var isTemporary: Bool

    public init(url: URL, isTemporary: Bool) {
        self.url = url
        self.isTemporary = isTemporary
    }

    public func cleanup() {
        guard isTemporary else {
            return
        }
        try? FileManager.default.removeItem(at: url)
    }
}
#endif
