import SwiftUI

/// Rating selector with continuous slider and benchmark descriptions.
/// Shows users their journey from learning to mastery with a tactile drag experience.
struct AssessmentPicker: View {
    @Binding var selectedRating: Rating
    let milestones: Skill.OutcomeMilestones
    var currentRating: Rating = .notAssessed
    var onRatingSelected: ((Rating) -> Void)? = nil
    var isSaving: Bool = false
    var showSaveSuccess: Bool = false

    var body: some View {
        VStack(spacing: TurnLabSpacing.md) {
            // Benchmark preview (always visible above slider)
            benchmarkPreview

            // Continuous slider
            ContinuousRatingSlider(
                selectedRating: $selectedRating,
                currentRating: currentRating,
                isSaving: isSaving,
                showSaveSuccess: showSaveSuccess,
                onRatingSelected: onRatingSelected
            )

            // Progress indicator (if not mastered)
            if selectedRating != .mastered && selectedRating != .notAssessed {
                progressToNextLevel
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedRating)
    }

    // MARK: - Benchmark Preview

    private var benchmarkPreview: some View {
        VStack(spacing: TurnLabSpacing.xs) {
            Text("What does \(selectedRating.encouragingName) mean?")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(TurnLabColors.textSecondary)

            Text(milestones.description(for: selectedRating))
                .font(TurnLabTypography.body)
                .foregroundStyle(TurnLabColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall)
                        .fill(selectedRating.color.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall)
                        .stroke(selectedRating.color.opacity(0.3), lineWidth: 1)
                )
        }
        .opacity(selectedRating == .notAssessed ? 0.5 : 1)
    }

    // MARK: - Progress Indicator

    private var progressToNextLevel: some View {
        VStack(spacing: 4) {
            if let next = selectedRating.nextLevel {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(.green)

                    Text("Next goal: \(next.encouragingName)")
                        .font(.caption)
                        .foregroundStyle(TurnLabColors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Continuous Rating Slider

struct ContinuousRatingSlider: View {
    @Binding var selectedRating: Rating
    var currentRating: Rating = .notAssessed
    var isSaving: Bool = false
    var showSaveSuccess: Bool = false
    var onRatingSelected: ((Rating) -> Void)? = nil

    /// Current drag position as a fraction 0...1
    @State private var dragProgress: CGFloat = 0
    @State private var isDragging = false
    @State private var lastHapticRating: Rating?

    private let ratings: [Rating] = [.needsWork, .developing, .confident, .mastered]
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let snapFeedback = UIImpactFeedbackGenerator(style: .rigid)

    var body: some View {
        VStack(spacing: TurnLabSpacing.sm) {
            // Header
            HStack {
                Text("Drag to assess")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(TurnLabColors.textSecondary)

                Spacer()

                if currentRating != .notAssessed && selectedRating != currentRating {
                    Text(selectedRating > currentRating ? "Improving!" : "")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
            }

            // Slider track with thumb
            GeometryReader { geometry in
                let trackWidth = geometry.size.width
                let thumbSize: CGFloat = 44
                let usableWidth = trackWidth - thumbSize
                let snapPositions = calculateSnapPositions(usableWidth: usableWidth, thumbSize: thumbSize)

                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 8)
                        .padding(.horizontal, thumbSize / 2)

                    // Filled progress track
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, thumbPosition(in: usableWidth) + thumbSize / 2), height: 8)
                        .padding(.leading, thumbSize / 2)

                    // Snap point indicators (emoji markers)
                    HStack(spacing: 0) {
                        ForEach(Array(ratings.enumerated()), id: \.element) { index, rating in
                            snapPointMarker(for: rating, at: index)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    // Draggable thumb
                    sliderThumb
                        .frame(width: thumbSize, height: thumbSize)
                        .offset(x: thumbPosition(in: usableWidth))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    handleDrag(value: value, usableWidth: usableWidth, snapPositions: snapPositions)
                                }
                                .onEnded { _ in
                                    handleDragEnd()
                                }
                        )
                }
                .frame(height: 60)
                .onAppear {
                    // Initialize drag progress from selected rating
                    dragProgress = progressForRating(selectedRating)
                }
                .onChange(of: selectedRating) { _, newRating in
                    if !isDragging {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragProgress = progressForRating(newRating)
                        }
                    }
                }
            }
            .frame(height: 60)

            // Rating labels below slider
            HStack(spacing: 0) {
                ForEach(ratings, id: \.self) { rating in
                    VStack(spacing: 2) {
                        Text(rating.encouragingName)
                            .font(.system(size: 10, weight: selectedRating == rating ? .bold : .medium))
                            .foregroundStyle(selectedRating == rating ? rating.color : TurnLabColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .disabled(isSaving)
    }

    // MARK: - Thumb View

    private var sliderThumb: some View {
        ZStack {
            // Outer glow when dragging
            if isDragging {
                Circle()
                    .fill(selectedRating.color.opacity(0.3))
                    .scaleEffect(1.3)
            }

            // Main thumb circle
            Circle()
                .fill(thumbBackgroundColor)
                .shadow(color: .black.opacity(0.2), radius: isDragging ? 8 : 4, y: isDragging ? 4 : 2)

            // Icon or status indicator
            if isSaving {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.7)
            } else if showSaveSuccess {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            } else {
                Text(selectedRating.emoji)
                    .font(.system(size: 20))
            }
        }
        .scaleEffect(isDragging ? 1.15 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isDragging)
    }

    // MARK: - Snap Point Marker

    private func snapPointMarker(for rating: Rating, at index: Int) -> some View {
        VStack(spacing: 4) {
            ZStack {
                // Background circle
                Circle()
                    .fill(markerBackgroundColor(for: rating))
                    .frame(width: 28, height: 28)

                // Emoji or checkmark
                if selectedRating.rawValue > rating.rawValue {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(rating.color)
                } else {
                    Text(rating.emoji)
                        .font(.system(size: 14))
                        .opacity(selectedRating == rating ? 0 : 0.7) // Hide if thumb is here
                }
            }
        }
    }

    // MARK: - Calculations

    private func calculateSnapPositions(usableWidth: CGFloat, thumbSize: CGFloat) -> [CGFloat] {
        return ratings.indices.map { index in
            let fraction = CGFloat(index) / CGFloat(ratings.count - 1)
            return fraction * usableWidth
        }
    }

    private func thumbPosition(in usableWidth: CGFloat) -> CGFloat {
        return dragProgress * usableWidth
    }

    private func progressForRating(_ rating: Rating) -> CGFloat {
        guard let index = ratings.firstIndex(of: rating) else {
            return 0
        }
        return CGFloat(index) / CGFloat(ratings.count - 1)
    }

    private func ratingForProgress(_ progress: CGFloat) -> Rating {
        let index = Int(round(progress * CGFloat(ratings.count - 1)))
        let clampedIndex = max(0, min(ratings.count - 1, index))
        return ratings[clampedIndex]
    }

    // MARK: - Drag Handling

    private func handleDrag(value: DragGesture.Value, usableWidth: CGFloat, snapPositions: [CGFloat]) {
        isDragging = true

        // Calculate new progress based on drag position
        let newProgress = max(0, min(1, value.location.x / usableWidth))
        dragProgress = newProgress

        // Determine current rating based on position
        let newRating = ratingForProgress(newProgress)

        // Trigger haptic when crossing to a new rating
        if newRating != lastHapticRating {
            hapticFeedback.impactOccurred()
            lastHapticRating = newRating
            selectedRating = newRating
        }
    }

    private func handleDragEnd() {
        isDragging = false

        // Snap to nearest rating
        let snappedRating = ratingForProgress(dragProgress)
        let snappedProgress = progressForRating(snappedRating)

        // Animate snap
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            dragProgress = snappedProgress
        }

        // Final haptic
        snapFeedback.impactOccurred()

        // Update selection and trigger callback
        selectedRating = snappedRating
        onRatingSelected?(snappedRating)

        lastHapticRating = nil
    }

    // MARK: - Colors

    private var gradientColors: [Color] {
        [Rating.needsWork.color, selectedRating.color]
    }

    private var thumbBackgroundColor: Color {
        if showSaveSuccess {
            return .green
        }
        return selectedRating.color
    }

    private func markerBackgroundColor(for rating: Rating) -> Color {
        if selectedRating.rawValue >= rating.rawValue {
            return rating.color.opacity(0.2)
        }
        return Color.gray.opacity(0.1)
    }
}

// MARK: - Rating Extension for Emoji & Encouraging Names

extension Rating {
    /// Emoji representation for the slider
    var emoji: String {
        switch self {
        case .notAssessed: return "❓"
        case .needsWork: return "🌱"
        case .developing: return "🌿"
        case .confident: return "🌲"
        case .mastered: return "⭐"
        }
    }

    /// More encouraging display names for the assessment picker.
    var encouragingName: String {
        switch self {
        case .notAssessed: return "Not Started"
        case .needsWork: return "Building"
        case .developing: return "Growing"
        case .confident: return "Solid"
        case .mastered: return "Expert"
        }
    }
}

// MARK: - Previews

#Preview("Slider Interactive") {
    struct PreviewWrapper: View {
        @State private var rating: Rating = .developing

        var body: some View {
            VStack(spacing: 24) {
                Text("How confident are you?")
                    .font(.headline)

                AssessmentPicker(
                    selectedRating: $rating,
                    milestones: Skill.OutcomeMilestones(
                        needsWork: "Skis frequently cross or wedge during turns",
                        developing: "Can make parallel turns on easy terrain with concentration",
                        confident: "Links parallel turns naturally on blue runs",
                        mastered: "Controls turn shape and speed with parallel technique on any groomed terrain"
                    ),
                    currentRating: .needsWork
                )

                Text("Selected: \(rating.encouragingName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Slider - Saving State") {
    AssessmentPicker(
        selectedRating: .constant(.confident),
        milestones: Skill.OutcomeMilestones(
            needsWork: "Building foundation",
            developing: "Growing stronger",
            confident: "Solid skills",
            mastered: "Expert level"
        ),
        currentRating: .developing,
        isSaving: true
    )
    .padding()
}

#Preview("Slider - Success State") {
    AssessmentPicker(
        selectedRating: .constant(.confident),
        milestones: Skill.OutcomeMilestones(
            needsWork: "Building foundation",
            developing: "Growing stronger",
            confident: "Solid skills",
            mastered: "Expert level"
        ),
        currentRating: .developing,
        showSaveSuccess: true
    )
    .padding()
}

#Preview("All Rating States") {
    ScrollView {
        VStack(spacing: 32) {
            ForEach([Rating.needsWork, .developing, .confident, .mastered], id: \.self) { rating in
                VStack {
                    Text("Selected: \(rating.encouragingName)")
                        .font(.caption)
                    AssessmentPicker(
                        selectedRating: .constant(rating),
                        milestones: Skill.OutcomeMilestones(
                            needsWork: "Building foundation with basic movements",
                            developing: "Growing stronger with consistent practice",
                            confident: "Solid skills across varied terrain",
                            mastered: "Expert-level control and adaptability"
                        )
                    )
                }
            }
        }
        .padding()
    }
}
