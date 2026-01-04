import SwiftUI

/// Generic content container card.
struct ContentCard<Content: View>: View {
    var title: String?
    var subtitle: String?
    var icon: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.sm) {
            // Header
            if title != nil || icon != nil {
                HStack(spacing: TurnLabSpacing.xs) {
                    if let icon {
                        Image(systemName: icon)
                            .foregroundStyle(Color.accentColor)
                    }

                    if let title {
                        Text(title)
                            .font(TurnLabTypography.headline)
                            .foregroundStyle(TurnLabColors.textPrimary)
                    }

                    Spacer()

                    if let subtitle {
                        Text(subtitle)
                            .font(TurnLabTypography.caption)
                            .foregroundStyle(TurnLabColors.textSecondary)
                    }
                }
            }

            // Content
            content()
        }
        .cardPadding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

#Preview {
    VStack(spacing: 16) {
        ContentCard(title: "Quick Tips", icon: "lightbulb") {
            Text("Keep your weight centered over your feet for better balance.")
                .font(.body)
        }

        ContentCard(title: "Statistics", subtitle: "This week") {
            HStack {
                VStack {
                    Text("12")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Skills")
                        .font(.caption)
                }
                Spacer()
                VStack {
                    Text("85%")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Progress")
                        .font(.caption)
                }
            }
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
