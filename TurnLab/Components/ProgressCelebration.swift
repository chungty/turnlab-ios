import SwiftUI

/// Celebration overlay shown when a user improves their skill rating.
/// Provides positive reinforcement and shows what's next in their journey.
struct ProgressCelebration: View {
    let skillName: String
    let previousRating: Rating
    let newRating: Rating
    let nextChallenge: String?
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Confetti particles
            if showConfetti {
                ConfettiView()
            }

            // Main content card
            VStack(spacing: TurnLabSpacing.lg) {
                // Trophy animation
                trophySection

                // Message
                messageSection

                // Progress visualization
                progressSection

                // Next challenge (if any)
                if let challenge = nextChallenge {
                    nextChallengeSection(challenge)
                }

                // Dismiss button
                dismissButton
            }
            .padding(TurnLabSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal, TurnLabSpacing.lg)
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showConfetti = true
                }
            }
        }
    }

    // MARK: - Trophy Section

    private var trophySection: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(newRating.color.opacity(0.2))
                .frame(width: 120, height: 120)
                .blur(radius: 20)

            // Trophy icon
            Image(systemName: celebrationIcon)
                .font(.system(size: 60))
                .foregroundStyle(newRating.color)
                .symbolEffect(.bounce, value: showContent)
        }
    }

    // MARK: - Message Section

    private var messageSection: some View {
        VStack(spacing: TurnLabSpacing.xs) {
            Text(celebrationTitle)
                .font(TurnLabTypography.title2)
                .fontWeight(.bold)
                .foregroundStyle(TurnLabColors.textPrimary)
                .multilineTextAlignment(.center)

            Text("You've improved at **\(skillName)**")
                .font(TurnLabTypography.body)
                .foregroundStyle(TurnLabColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        HStack(spacing: TurnLabSpacing.md) {
            // Previous rating
            VStack(spacing: 4) {
                Image(systemName: previousRating.iconName)
                    .font(.title2)
                    .foregroundStyle(previousRating.color.opacity(0.5))
                Text(previousRating.encouragingName)
                    .font(.caption)
                    .foregroundStyle(TurnLabColors.textTertiary)
            }

            // Arrow
            Image(systemName: "arrow.right")
                .font(.title3)
                .foregroundStyle(.green)

            // New rating
            VStack(spacing: 4) {
                Image(systemName: newRating.iconName)
                    .font(.title2)
                    .foregroundStyle(newRating.color)
                    .symbolEffect(.pulse.wholeSymbol, options: .repeating)
                Text(newRating.encouragingName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(newRating.color)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall)
                .fill(Color(.secondarySystemBackground))
        )
    }

    // MARK: - Next Challenge Section

    private func nextChallengeSection(_ challenge: String) -> some View {
        VStack(spacing: TurnLabSpacing.xs) {
            Label("Next Challenge", systemImage: "flag.fill")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(TurnLabColors.textSecondary)

            Text(challenge)
                .font(TurnLabTypography.caption)
                .foregroundStyle(TurnLabColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall)
                .fill(Color.accentColor.opacity(0.1))
        )
    }

    // MARK: - Dismiss Button

    private var dismissButton: some View {
        Button(action: dismiss) {
            Text("Continue")
                .font(TurnLabTypography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, TurnLabSpacing.sm)
                .background(newRating.color)
                .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall))
        }
    }

    // MARK: - Helpers

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            showContent = false
            showConfetti = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }

    private var celebrationTitle: String {
        switch newRating {
        case .developing:
            return "You're Growing!"
        case .confident:
            return "Solid Progress!"
        case .mastered:
            return "Mastery Achieved!"
        default:
            return "Nice Work!"
        }
    }

    private var celebrationIcon: String {
        switch newRating {
        case .mastered:
            return "trophy.fill"
        case .confident:
            return "medal.fill"
        case .developing:
            return "star.fill"
        default:
            return "checkmark.circle.fill"
        }
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<30, id: \.self) { index in
                    ConfettiPiece(
                        color: colors[index % colors.count],
                        size: geometry.size,
                        delay: Double(index) * 0.05
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct ConfettiPiece: View {
    let color: Color
    let size: CGSize
    let delay: Double

    @State private var offsetY: CGFloat = -100
    @State private var offsetX: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 6...12))
            .rotationEffect(.degrees(rotation))
            .offset(x: offsetX, y: offsetY)
            .opacity(opacity)
            .onAppear {
                let startX = CGFloat.random(in: -size.width/3...size.width/3)
                offsetX = startX

                withAnimation(.easeOut(duration: 2).delay(delay)) {
                    offsetY = size.height + 100
                    offsetX = startX + CGFloat.random(in: -100...100)
                    rotation = Double.random(in: 360...720)
                }

                withAnimation(.easeIn(duration: 0.5).delay(delay + 1.5)) {
                    opacity = 0
                }
            }
    }
}

// MARK: - View Modifier for Easy Use

extension View {
    /// Presents a celebration overlay when the rating improves.
    func progressCelebration(
        isPresented: Binding<Bool>,
        skillName: String,
        previousRating: Rating,
        newRating: Rating,
        nextChallenge: String? = nil
    ) -> some View {
        ZStack {
            self

            if isPresented.wrappedValue {
                ProgressCelebration(
                    skillName: skillName,
                    previousRating: previousRating,
                    newRating: newRating,
                    nextChallenge: nextChallenge,
                    onDismiss: { isPresented.wrappedValue = false }
                )
            }
        }
    }
}

#Preview("Developing to Confident") {
    Color.clear
        .progressCelebration(
            isPresented: .constant(true),
            skillName: "Parallel Turns",
            previousRating: .developing,
            newRating: .confident,
            nextChallenge: "Try maintaining parallel stance through varied turn shapes and speeds on blue runs"
        )
}

#Preview("Confident to Mastered") {
    Color.clear
        .progressCelebration(
            isPresented: .constant(true),
            skillName: "Hockey Stop",
            previousRating: .confident,
            newRating: .mastered,
            nextChallenge: nil
        )
}

#Preview("Needs Work to Developing") {
    Color.clear
        .progressCelebration(
            isPresented: .constant(true),
            skillName: "Pole Plants",
            previousRating: .needsWork,
            newRating: .developing,
            nextChallenge: "Focus on consistent timing - plant the pole at the moment you initiate each turn"
        )
}
