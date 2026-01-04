import SwiftUI

/// Card showing current level and progress toward next level.
struct LevelProgressCard: View {
    let level: SkillLevel
    let progress: Double
    let canAdvance: Bool
    let nextLevel: SkillLevel?

    var body: some View {
        ContentCard {
            VStack(spacing: TurnLabSpacing.md) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: TurnLabSpacing.xxs) {
                        Text("Current Level")
                            .font(TurnLabTypography.caption)
                            .foregroundStyle(TurnLabColors.textSecondary)

                        HStack(spacing: TurnLabSpacing.xs) {
                            LevelBadge(level: level, size: .large)

                            if canAdvance, let next = nextLevel {
                                Image(systemName: "arrow.right")
                                    .foregroundStyle(TurnLabColors.textTertiary)
                                LevelBadge(level: next, size: .medium)
                            }
                        }
                    }

                    Spacer()

                    // Progress ring
                    ProgressRing(
                        progress: progress,
                        size: 70,
                        foregroundColor: TurnLabColors.levelColor(level)
                    )
                }

                // Progress bar
                VStack(alignment: .leading, spacing: TurnLabSpacing.xxs) {
                    HStack {
                        Text("Progress to \(nextLevel?.displayName ?? "Mastery")")
                            .font(TurnLabTypography.caption)
                            .foregroundStyle(TurnLabColors.textSecondary)

                        Spacer()

                        Text("\(Int(progress * 100))%")
                            .font(TurnLabTypography.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(TurnLabColors.levelColor(level))
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(TurnLabColors.levelColor(level).opacity(0.2))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(TurnLabColors.levelColor(level))
                                .frame(width: geometry.size.width * CGFloat(progress))

                            // Threshold marker
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 2)
                                .offset(x: geometry.size.width * CGFloat(SkillLevel.unlockThreshold) - 1)
                        }
                    }
                    .frame(height: 8)

                    // Threshold label
                    Text("Need \(Int(SkillLevel.unlockThreshold * 100))% at Confident to advance")
                        .font(.caption2)
                        .foregroundStyle(TurnLabColors.textTertiary)
                }

                // Advance button if ready
                if canAdvance, let next = nextLevel {
                    PrimaryButton(
                        title: "Advance to \(next.displayName)",
                        icon: "arrow.up.circle"
                    ) {
                        // Handle level advancement
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        LevelProgressCard(
            level: .beginner,
            progress: 0.65,
            canAdvance: false,
            nextLevel: .novice
        )

        LevelProgressCard(
            level: .intermediate,
            progress: 0.85,
            canAdvance: true,
            nextLevel: .expert
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
