import SwiftUI

/// Expandable card displaying a practice drill.
struct DrillCard: View {
    let drill: Drill
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header (always visible)
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(drill.title)
                            .font(TurnLabTypography.headline)
                            .foregroundStyle(TurnLabColors.textPrimary)

                        HStack(spacing: 8) {
                            // Difficulty
                            Label(drill.difficulty.displayName, systemImage: "chart.bar.fill")
                                .font(.caption)
                                .foregroundStyle(difficultyColor)

                            // Steps count
                            Label("\(drill.steps.count) steps", systemImage: "list.number")
                                .font(.caption)
                                .foregroundStyle(TurnLabColors.textSecondary)

                            // Reps
                            if let reps = drill.estimatedReps {
                                Label(reps, systemImage: "repeat")
                                    .font(.caption)
                                    .foregroundStyle(TurnLabColors.textSecondary)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(TurnLabColors.textTertiary)
                }
                .cardPadding()
            }
            .buttonStyle(.plain)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: TurnLabSpacing.md) {
                    // Overview
                    Text(drill.overview)
                        .font(TurnLabTypography.callout)
                        .foregroundStyle(TurnLabColors.textSecondary)

                    // Recommended terrain
                    if !drill.recommendedTerrain.isEmpty {
                        HStack(spacing: 6) {
                            Text("Best on:")
                                .font(.caption)
                                .foregroundStyle(TurnLabColors.textTertiary)
                            ForEach(drill.recommendedTerrain) { terrain in
                                Text(terrain.shortName)
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor)
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    Divider()

                    // Steps
                    VStack(alignment: .leading, spacing: TurnLabSpacing.sm) {
                        ForEach(drill.steps) { step in
                            DrillStepRow(step: step)
                        }
                    }
                }
                .padding(.horizontal, TurnLabSpacing.cardPadding)
                .padding(.bottom, TurnLabSpacing.cardPadding)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
    }

    private var difficultyColor: Color {
        switch drill.difficulty {
        case .easy: return .green
        case .moderate: return .orange
        case .challenging: return .red
        }
    }
}

struct DrillStepRow: View {
    let step: Drill.DrillStep

    var body: some View {
        HStack(alignment: .top, spacing: TurnLabSpacing.sm) {
            // Step number
            Text("\(step.order)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.accentColor))

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(step.instruction)
                    .font(TurnLabTypography.body)
                    .foregroundStyle(TurnLabColors.textPrimary)

                if let focus = step.focusPoint {
                    Label(focus, systemImage: "eye")
                        .font(.caption)
                        .foregroundStyle(TurnLabColors.textSecondary)
                }
            }
        }
    }
}

#Preview {
    DrillCard(
        drill: Drill(
            id: "1",
            title: "Traverse and Turn Practice",
            overview: "Practice making turns from a traverse position to improve edge awareness and turn initiation.",
            steps: [
                Drill.DrillStep(order: 1, instruction: "Start in a traverse across the hill on your uphill edges", focusPoint: "Feel the edges gripping"),
                Drill.DrillStep(order: 2, instruction: "Gradually shift weight to your downhill ski", focusPoint: nil),
                Drill.DrillStep(order: 3, instruction: "Allow the skis to pivot and complete the turn", focusPoint: "Keep upper body facing downhill")
            ],
            difficulty: .moderate,
            recommendedTerrain: [.groomedBlue, .groomedGreen],
            estimatedReps: "10 each way"
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
