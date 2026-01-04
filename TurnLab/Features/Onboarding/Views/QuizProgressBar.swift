import SwiftUI

/// Progress bar for quiz completion.
struct QuizProgressBar: View {
    let progress: Double

    var body: some View {
        VStack(spacing: TurnLabSpacing.xxs) {
            // Progress text
            HStack {
                Text("Skill Assessment")
                    .font(TurnLabTypography.caption)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(TurnLabTypography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.3))

                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white)
                        .frame(width: geometry.size.width * CGFloat(progress))
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    ZStack {
        MountainBackgroundView()

        VStack(spacing: 20) {
            QuizProgressBar(progress: 0.25)
            QuizProgressBar(progress: 0.5)
            QuizProgressBar(progress: 0.75)
            QuizProgressBar(progress: 1.0)
        }
        .padding()
    }
}
