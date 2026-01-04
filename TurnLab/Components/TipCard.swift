import SwiftUI

/// Card displaying an instructional tip.
struct TipCard: View {
    let tip: Tip
    var isExpanded: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
            // Header
            HStack(spacing: TurnLabSpacing.xs) {
                Image(systemName: tip.category.iconName)
                    .foregroundStyle(categoryColor)

                Text(tip.title)
                    .font(TurnLabTypography.headline)
                    .foregroundStyle(TurnLabColors.textPrimary)

                Spacer()

                if tip.isQuickReference {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }

            // Content
            if isExpanded {
                Text(tip.content)
                    .font(TurnLabTypography.body)
                    .foregroundStyle(TurnLabColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Category badge
            Text(tip.category.displayName)
                .font(.caption2)
                .foregroundStyle(categoryColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(categoryColor.opacity(0.1))
                .clipShape(Capsule())
        }
        .cardPadding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
    }

    private var categoryColor: Color {
        switch tip.category {
        case .mentalCue: return .purple
        case .bodyPosition: return .blue
        case .movement: return .green
        case .focus: return .orange
        case .common_mistake: return .red
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        TipCard(
            tip: Tip(
                id: "1",
                title: "Lazy Susan Feet",
                content: "Imagine your feet are on a lazy Susan, rotating together as one unit. This helps maintain parallel ski positioning throughout the turn.",
                category: .mentalCue,
                isQuickReference: true
            )
        )

        TipCard(
            tip: Tip(
                id: "2",
                title: "Hands Forward",
                content: "Keep your hands in front of you, as if holding a serving tray. This promotes proper upper body positioning.",
                category: .bodyPosition,
                isQuickReference: false
            )
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
