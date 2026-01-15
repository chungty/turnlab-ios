import SwiftUI

/// Card displaying YouTube video thumbnail that opens in YouTube app or Safari.
/// Uses external link approach for reliability - inline WKWebView embedding
/// has cross-origin security issues and ATS configuration requirements.
struct YouTubePlayerCard: View {
    let video: VideoReference

    var body: some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
            // Thumbnail with play button overlay
            Button(action: openYouTube) {
                ZStack {
                    // Video thumbnail
                    AsyncImage(url: video.thumbnailURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .aspectRatio(16/9, contentMode: .fit)
                                .overlay {
                                    Image(systemName: "video.slash")
                                        .font(.title)
                                        .foregroundStyle(TurnLabColors.textTertiary)
                                }
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .aspectRatio(16/9, contentMode: .fit)
                                .overlay {
                                    ProgressView()
                                }
                        @unknown default:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .aspectRatio(16/9, contentMode: .fit)
                        }
                    }

                    // Dark overlay for contrast
                    Rectangle()
                        .fill(.black.opacity(0.2))

                    // Play button + "Watch on YouTube" indicator
                    VStack(spacing: 8) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4)

                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.forward.square")
                                .font(.caption2)
                            Text("Watch on YouTube")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.7))
                        .clipShape(Capsule())
                    }

                    // Duration badge (bottom right)
                    if let duration = video.formattedDuration {
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
            }
            .buttonStyle(.plain)
            .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall))

            // Video info
            VStack(alignment: .leading, spacing: 2) {
                Text(video.title)
                    .font(TurnLabTypography.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundStyle(TurnLabColors.textPrimary)

                HStack(spacing: 4) {
                    Text(video.channelName)
                        .font(TurnLabTypography.caption)
                        .foregroundStyle(TurnLabColors.textSecondary)

                    if let duration = video.formattedDuration {
                        Text("•")
                            .foregroundStyle(TurnLabColors.textTertiary)
                        Text(duration)
                            .font(TurnLabTypography.caption)
                            .foregroundStyle(TurnLabColors.textSecondary)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Video: \(video.title) by \(video.channelName)")
        .accessibilityHint("Double tap to open in YouTube")
    }

    /// Opens the video in YouTube app if installed, otherwise Safari
    private func openYouTube() {
        // YouTube app URL scheme
        let youtubeAppURL = URL(string: "youtube://watch?v=\(video.youtubeId)")

        // Web fallback URL
        let youtubeWebURL = URL(string: "https://www.youtube.com/watch?v=\(video.youtubeId)")!

        // Try YouTube app first, fall back to Safari
        if let appURL = youtubeAppURL, UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else {
            UIApplication.shared.open(youtubeWebURL)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        YouTubePlayerCard(
            video: VideoReference(
                id: "1",
                title: "How to Ski Parallel Turns - Complete Tutorial",
                youtubeId: "dQw4w9WgXcQ",
                channelName: "Stomp It Tutorials",
                duration: 425,
                isPrimary: true
            )
        )

        YouTubePlayerCard(
            video: VideoReference(
                id: "2",
                title: "Short Video",
                youtubeId: "abc123",
                channelName: "Ski School",
                duration: 90,
                isPrimary: false
            )
        )
    }
    .padding()
}
