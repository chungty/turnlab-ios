import SwiftUI

/// Section showing progress through all levels.
struct LevelProgressionSection: View {
    let levelProgress: [SkillLevel: Double]
    let currentLevel: SkillLevel

    var body: some View {
        ContentCard(title: "Level Progression", icon: "chart.line.uptrend.xyaxis") {
            VStack(spacing: TurnLabSpacing.md) {
                ForEach(SkillLevel.allCases, id: \.self) { level in
                    LevelProgressRow(
                        level: level,
                        progress: levelProgress[level] ?? 0,
                        isCurrent: level == currentLevel,
                        isCompleted: level < currentLevel
                    )
                }
            }
        }
    }
}

struct LevelProgressRow: View {
    let level: SkillLevel
    let progress: Double
    let isCurrent: Bool
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: TurnLabSpacing.sm) {
            // Status icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 32, height: 32)

                Image(systemName: statusIcon)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }

            // Level name
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(level.displayName)
                        .font(isCurrent ? TurnLabTypography.headline : TurnLabTypography.body)
                        .foregroundStyle(TurnLabColors.textPrimary)

                    if isCurrent {
                        Text("Current")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(TurnLabColors.levelColor(level))
                            .clipShape(Capsule())
                    }
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.2))

                        RoundedRectangle(cornerRadius: 3)
                            .fill(TurnLabColors.levelColor(level))
                            .frame(width: geometry.size.width * CGFloat(progress))
                    }
                }
                .frame(height: 6)
            }

            // Percentage
            Text("\(Int(progress * 100))%")
                .font(TurnLabTypography.caption)
                .fontWeight(.semibold)
                .foregroundStyle(TurnLabColors.levelColor(level))
                .frame(width: 44, alignment: .trailing)
        }
    }

    private var statusColor: Color {
        if isCompleted {
            return .green
        } else if isCurrent {
            return TurnLabColors.levelColor(level)
        } else {
            return .gray
        }
    }

    private var statusIcon: String {
        if isCompleted {
            return "checkmark"
        } else if isCurrent {
            return "arrow.right"
        } else {
            return "lock"
        }
    }
}

#Preview {
    LevelProgressionSection(
        levelProgress: [
            .beginner: 1.0,
            .novice: 0.65,
            .intermediate: 0.2,
            .expert: 0.0
        ],
        currentLevel: .novice
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
