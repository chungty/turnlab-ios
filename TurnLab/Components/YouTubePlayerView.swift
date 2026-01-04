import SwiftUI
import WebKit

/// YouTube video player using WKWebView iframe embed.
struct YouTubePlayerView: UIViewRepresentable {
    let video: VideoReference

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; }
                html, body { width: 100%; height: 100%; background: #000; }
                iframe { width: 100%; height: 100%; border: none; }
            </style>
        </head>
        <body>
            <iframe
                src="https://www.youtube.com/embed/\(video.youtubeId)?playsinline=1&rel=0&modestbranding=1"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen>
            </iframe>
        </body>
        </html>
        """

        webView.loadHTMLString(embedHTML, baseURL: nil)
    }
}

/// Container for YouTube player with thumbnail preview.
struct YouTubePlayerCard: View {
    let video: VideoReference
    @State private var isPlaying = false

    var body: some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
            // Player/Thumbnail
            ZStack {
                if isPlaying {
                    YouTubePlayerView(video: video)
                        .aspectRatio(16/9, contentMode: .fit)
                } else {
                    // Thumbnail with play button
                    AsyncImage(url: video.thumbnailURL) { image in
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(16/9, contentMode: .fit)
                    }

                    // Play button overlay
                    Button(action: { isPlaying = true }) {
                        ZStack {
                            Circle()
                                .fill(.black.opacity(0.7))
                                .frame(width: 64, height: 64)

                            Image(systemName: "play.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                    }
                }

                // Duration badge
                if let duration = video.formattedDuration, !isPlaying {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(duration)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.black.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .padding(8)
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall))

            // Video info
            VStack(alignment: .leading, spacing: 2) {
                Text(video.title)
                    .font(TurnLabTypography.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                Text(video.channelName)
                    .font(TurnLabTypography.caption)
                    .foregroundStyle(TurnLabColors.textSecondary)
            }
        }
    }
}

#Preview {
    YouTubePlayerCard(
        video: VideoReference(
            id: "1",
            title: "How to Ski Parallel Turns",
            youtubeId: "dQw4w9WgXcQ",
            channelName: "Stomp It Tutorials",
            duration: 425,
            isPrimary: true
        )
    )
    .padding()
}
