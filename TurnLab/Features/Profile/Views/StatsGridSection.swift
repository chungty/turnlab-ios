import SwiftUI

/// Grid of statistics for the profile view.
struct StatsGridSection: View {
    let totalAssessments: Int
    let confidentSkills: Int
    let completionPercentage: Double

    var body: some View {
        ContentCard(title: "Statistics", icon: "chart.bar.fill") {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: TurnLabSpacing.md) {
                StatBox(
                    value: "\(totalAssessments)",
                    label: "Assessed",
                    icon: "checkmark.circle",
                    color: .blue
                )

                StatBox(
                    value: "\(confidentSkills)",
                    label: "Confident",
                    icon: "star.fill",
                    color: .green
                )

                StatBox(
                    value: "\(Int(completionPercentage * 100))%",
                    label: "Complete",
                    icon: "chart.pie.fill",
                    color: .orange
                )
            }
        }
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: TurnLabSpacing.xxs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(TurnLabTypography.statValue)
                .foregroundStyle(TurnLabColors.textPrimary)

            Text(label)
                .font(TurnLabTypography.caption)
                .foregroundStyle(TurnLabColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall))
    }
}

#Preview {
    StatsGridSection(
        totalAssessments: 24,
        confidentSkills: 12,
        completionPercentage: 0.45
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
