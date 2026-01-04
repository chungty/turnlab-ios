import SwiftUI

/// Videos tab content.
struct VideoContentTab: View {
    let videos: [VideoReference]

    var body: some View {
        if videos.isEmpty {
            EmptyStateView(
                icon: "play.rectangle",
                title: "No Videos",
                message: "Video content is coming soon for this skill."
            )
        } else {
            VStack(spacing: TurnLabSpacing.md) {
                ForEach(videos) { video in
                    YouTubePlayerCard(video: video)
                }
            }
        }
    }
}

#Preview {
    VideoContentTab(
        videos: [
            VideoReference(
                id: "1",
                title: "How to Ski Parallel Turns",
                youtubeId: "dQw4w9WgXcQ",
                channelName: "Stomp It Tutorials",
                duration: 425,
                isPrimary: true
            ),
            VideoReference(
                id: "2",
                title: "Common Parallel Turn Mistakes",
                youtubeId: "dQw4w9WgXcQ",
                channelName: "Ski School by Elate",
                duration: 312,
                isPrimary: false
            )
        ]
    )
    .padding()
}
