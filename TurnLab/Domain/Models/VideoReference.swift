import Foundation

/// Reference to an external YouTube video.
/// Videos are not stored locally; only metadata for embedding.
struct VideoReference: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let youtubeId: String
    let channelName: String
    let duration: TimeInterval?
    let isPrimary: Bool

    /// YouTube embed URL for iframe playback
    var embedURL: URL? {
        URL(string: "https://www.youtube.com/embed/\(youtubeId)?playsinline=1&rel=0")
    }

    /// YouTube watch URL for external linking
    var watchURL: URL? {
        URL(string: "https://www.youtube.com/watch?v=\(youtubeId)")
    }

    /// Thumbnail URL for preview
    var thumbnailURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(youtubeId)/hqdefault.jpg")
    }

    /// Formatted duration string (e.g., "5:30")
    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
