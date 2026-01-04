import SwiftUI

/// View showing assessment history for a skill.
struct AssessmentHistoryView: View {
    let assessments: [AssessmentEntity]

    var body: some View {
        if assessments.isEmpty {
            EmptyStateView(
                icon: "clock",
                title: "No History",
                message: "Your assessment history will appear here."
            )
        } else {
            VStack(alignment: .leading, spacing: TurnLabSpacing.sm) {
                ForEach(assessments, id: \.id) { assessment in
                    AssessmentHistoryRow(assessment: assessment)
                }
            }
        }
    }
}

struct AssessmentHistoryRow: View {
    let assessment: AssessmentEntity

    var body: some View {
        HStack(spacing: TurnLabSpacing.sm) {
            // Rating indicator
            Image(systemName: assessment.ratingValue.iconName)
                .font(.title3)
                .foregroundStyle(assessment.ratingValue.color)
                .frame(width: 32)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(assessment.ratingValue.displayName)
                        .font(TurnLabTypography.headline)
                        .foregroundStyle(TurnLabColors.textPrimary)

                    if let context = assessment.terrainContext {
                        Text("on \(context.shortName)")
                            .font(TurnLabTypography.caption)
                            .foregroundStyle(TurnLabColors.textSecondary)
                    }
                }

                Text(assessment.date, style: .date)
                    .font(TurnLabTypography.caption)
                    .foregroundStyle(TurnLabColors.textTertiary)

                if let notes = assessment.notes, !notes.isEmpty {
                    Text(notes)
                        .font(TurnLabTypography.caption)
                        .foregroundStyle(TurnLabColors.textSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall))
    }
}

#Preview {
    ScrollView {
        AssessmentHistoryView(assessments: [])
    }
    .background(Color(.systemGroupedBackground))
}
