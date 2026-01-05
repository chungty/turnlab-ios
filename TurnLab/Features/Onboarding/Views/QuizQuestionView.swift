import SwiftUI

/// Displays a single quiz question with answer options.
struct QuizQuestionView: View {
    let question: QuizQuestion
    let selectedOptionId: String?
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TurnLabSpacing.lg) {
                // Scenario text
                Text(question.scenario)
                    .font(TurnLabTypography.title3)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .padding(.top, TurnLabSpacing.xl)
                    .accessibilityIdentifier("quiz_question_scenario")

                // Options
                VStack(spacing: TurnLabSpacing.sm) {
                    ForEach(question.options) { option in
                        QuizOptionButton(
                            option: option,
                            isSelected: selectedOptionId == option.id,
                            onSelect: { onSelect(option.id) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct QuizOptionButton: View {
    let option: QuizQuestion.QuizOption
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: TurnLabSpacing.sm) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.white : Color.white.opacity(0.5), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 14, height: 14)
                    }
                }

                // Option text
                Text(option.text)
                    .font(TurnLabTypography.body)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium)
                    .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
            }
            .overlay {
                RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium)
                    .stroke(isSelected ? Color.white : Color.white.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .accessibilityIdentifier("quiz_option_\(option.id)")
    }
}

#Preview {
    ZStack {
        MountainBackgroundView()

        QuizQuestionView(
            question: QuizQuestion(
                id: "1",
                scenario: "On a gentle green run, you typically:",
                options: [
                    QuizQuestion.QuizOption(id: "a", text: "Feel nervous and use a snowplow most of the time", levelPoints: [:]),
                    QuizQuestion.QuizOption(id: "b", text: "Ski comfortably with wedge turns", levelPoints: [:]),
                    QuizQuestion.QuizOption(id: "c", text: "Ski with parallel turns easily", levelPoints: [:]),
                    QuizQuestion.QuizOption(id: "d", text: "Find it too easy and look for steeper terrain", levelPoints: [:])
                ],
                order: 1
            ),
            selectedOptionId: "b",
            onSelect: { _ in }
        )
    }
}
