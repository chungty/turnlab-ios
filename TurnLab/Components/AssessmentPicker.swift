import SwiftUI

/// Rating selector with benchmark descriptions.
struct AssessmentPicker: View {
    @Binding var selectedRating: Rating
    let milestones: Skill.OutcomeMilestones

    var body: some View {
        VStack(spacing: TurnLabSpacing.md) {
            // Rating buttons
            HStack(spacing: TurnLabSpacing.xs) {
                ForEach(Rating.allCases.filter { $0 != .notAssessed }, id: \.self) { rating in
                    RatingButton(
                        rating: rating,
                        isSelected: selectedRating == rating,
                        action: { selectedRating = rating }
                    )
                }
            }

            // Benchmark description
            if selectedRating != .notAssessed {
                Text(milestones.description(for: selectedRating))
                    .font(TurnLabTypography.callout)
                    .foregroundStyle(TurnLabColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedRating)
    }
}

struct RatingButton: View {
    let rating: Rating
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: rating.iconName)
                    .font(.title2)
                Text(rating.shortName)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TurnLabSpacing.sm)
            .foregroundStyle(isSelected ? .white : rating.color)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall)
                        .fill(rating.color)
                } else {
                    RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall)
                        .stroke(rating.color.opacity(0.5), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var rating: Rating = .developing

        var body: some View {
            AssessmentPicker(
                selectedRating: $rating,
                milestones: Skill.OutcomeMilestones(
                    needsWork: "Skis frequently cross or wedge during turns",
                    developing: "Can make parallel turns on easy terrain with concentration",
                    confident: "Links parallel turns naturally on blue runs",
                    mastered: "Controls turn shape and speed with parallel technique on any groomed terrain"
                )
            )
            .padding()
        }
    }

    return PreviewWrapper()
}
