import SwiftUI

/// Card displaying an instructional tip.
/// Mental cue tips receive special visual treatment as they're the app's key differentiator.
struct TipCard: View {
    let tip: Tip
    var isExpanded: Bool = true

    private var isMentalCue: Bool {
        tip.category == .mentalCue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
            // Special mental cue banner
            if isMentalCue {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 12, weight: .semibold))
                    Text("MENTAL CUE")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.5)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color.purple.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
            }

            // Header
            HStack(spacing: TurnLabSpacing.xs) {
                Image(systemName: isMentalCue ? "lightbulb.fill" : tip.category.iconName)
                    .foregroundStyle(categoryColor)
                    .font(isMentalCue ? .system(size: 18) : .body)

                Text(tip.title)
                    .font(isMentalCue ? TurnLabTypography.title3 : TurnLabTypography.headline)
                    .fontWeight(isMentalCue ? .bold : .semibold)
                    .foregroundStyle(TurnLabColors.textPrimary)

                Spacer()

                if tip.isQuickReference {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.caption)
                        Text("Quick")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.yellow.opacity(0.15))
                    .clipShape(Capsule())
                }
            }

            // Content
            if isExpanded {
                Text(tip.content)
                    .font(isMentalCue ? TurnLabTypography.body : TurnLabTypography.body)
                    .foregroundStyle(isMentalCue ? TurnLabColors.textPrimary : TurnLabColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Emphasis callout for mental cues
                if isMentalCue {
                    HStack(spacing: 6) {
                        Image(systemName: "quote.opening")
                            .font(.caption)
                            .foregroundStyle(.purple.opacity(0.6))
                        Text("Use this image while skiing")
                            .font(.caption)
                            .italic()
                            .foregroundStyle(TurnLabColors.textTertiary)
                    }
                    .padding(.top, 4)
                }
            }

            // Category badge (only for non-mental-cue tips)
            if !isMentalCue {
                Text(tip.category.displayName)
                    .font(.caption2)
                    .foregroundStyle(categoryColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(categoryColor.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .cardPadding()
        .background(
            isMentalCue
                ? AnyShapeStyle(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.08), Color.purple.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                : AnyShapeStyle(Color(.systemBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium)
                .stroke(
                    isMentalCue ? Color.purple.opacity(0.3) : Color.clear,
                    lineWidth: isMentalCue ? 1.5 : 0
                )
        )
        .shadow(
            color: isMentalCue ? Color.purple.opacity(0.15) : Color.clear,
            radius: isMentalCue ? 6 : 0,
            y: isMentalCue ? 2 : 0
        )
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

#Preview("Mental Cue vs Regular") {
    ScrollView {
        VStack(spacing: 16) {
            Text("Mental Cue (Key Differentiator)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            TipCard(
                tip: Tip(
                    id: "1",
                    title: "Lazy Susan Feet",
                    content: "Imagine your feet are on a lazy Susan, rotating together as one unit. This helps maintain parallel ski positioning throughout the turn.",
                    category: .mentalCue,
                    isQuickReference: true
                )
            )

            Text("Regular Tips")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)

            TipCard(
                tip: Tip(
                    id: "2",
                    title: "Hands Forward",
                    content: "Keep your hands in front of you, as if holding a serving tray. This promotes proper upper body positioning.",
                    category: .bodyPosition,
                    isQuickReference: false
                )
            )

            TipCard(
                tip: Tip(
                    id: "3",
                    title: "Weight Transfer",
                    content: "Shift your weight progressively from one ski to the other through the turn.",
                    category: .movement,
                    isQuickReference: true
                )
            )

            TipCard(
                tip: Tip(
                    id: "4",
                    title: "Sitting Back",
                    content: "Avoid leaning back - this makes your skis harder to control and leads to fatigue.",
                    category: .common_mistake,
                    isQuickReference: false
                )
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
