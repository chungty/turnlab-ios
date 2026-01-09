import SwiftUI

/// Card showing current level and progress toward next level.
struct LevelProgressCard: View {
    let level: SkillLevel
    let progress: Double
    let canAdvance: Bool
    let nextLevel: SkillLevel?
    var onAdvance: (() -> Void)?

    var body: some View {
        VStack(spacing: TurnLabSpacing.md) {
            // Header with level gradient
            HStack {
                VStack(alignment: .leading, spacing: TurnLabSpacing.xxs) {
                    Text("Your Journey")
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

                // Progress ring with glow effect
                ZStack {
                    Circle()
                        .fill(TurnLabColors.levelColor(level).opacity(0.15))
                        .frame(width: 80, height: 80)

                    ProgressRing(
                        progress: progress,
                        size: 70,
                        foregroundColor: TurnLabColors.levelColor(level)
                    )
                }
            }

            // Progress visualization
            VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                HStack {
                    Text("Progress to \(nextLevel?.displayName ?? "Mastery")")
                        .font(TurnLabTypography.caption)
                        .foregroundStyle(TurnLabColors.textSecondary)

                    Spacer()

                    Text("\(Int(progress * 100))%")
                        .font(TurnLabTypography.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(TurnLabColors.levelColor(level))
                }

                // Animated progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 6)
                            .fill(TurnLabColors.levelColor(level).opacity(0.15))

                        // Progress fill with gradient
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        TurnLabColors.levelColor(level).opacity(0.8),
                                        TurnLabColors.levelColor(level)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(max(0.02, progress)))

                        // Threshold marker
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2, height: 16)
                            .offset(x: geometry.size.width * CGFloat(SkillLevel.unlockThreshold) - 1)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    }
                }
                .frame(height: 12)

                // Threshold label
                HStack {
                    Image(systemName: "flag.fill")
                        .font(.caption2)
                        .foregroundStyle(TurnLabColors.textTertiary)
                    Text("\(Int(SkillLevel.unlockThreshold * 100))% needed to advance")
                        .font(.caption2)
                        .foregroundStyle(TurnLabColors.textTertiary)
                }
            }

            // Advance button if ready
            if canAdvance, let next = nextLevel {
                PrimaryButton(
                    title: "Advance to \(next.displayName)",
                    icon: "arrow.up.circle"
                ) {
                    onAdvance?()
                }
            }
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium)
                .fill(Color(.systemBackground))
                .shadow(color: TurnLabColors.levelColor(level).opacity(0.1), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium)
                .stroke(TurnLabColors.levelColor(level).opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        LevelProgressCard(
            level: .beginner,
            progress: 0.65,
            canAdvance: false,
            nextLevel: .novice,
            onAdvance: nil
        )

        LevelProgressCard(
            level: .intermediate,
            progress: 0.85,
            canAdvance: true,
            nextLevel: .expert,
            onAdvance: { print("Advancing to Expert!") }
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
