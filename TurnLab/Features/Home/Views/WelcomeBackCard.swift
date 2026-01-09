import SwiftUI

/// Card shown to returning users summarizing their progress and encouraging continuation.
/// Designed to help users quickly re-orient after time away from the app.
struct WelcomeBackCard: View {
    let lastVisit: Date?
    let focusSkillName: String?
    let currentRating: Rating?
    let onContinue: () -> Void
    let onDismiss: () -> Void

    @State private var isVisible = true

    var body: some View {
        if isVisible {
            VStack(alignment: .leading, spacing: TurnLabSpacing.md) {
                // Header
                headerSection

                // Summary content
                if focusSkillName != nil {
                    progressSummary
                }

                Divider()

                // Actions
                actionSection
            }
            .padding(TurnLabSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium)
                    .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
            )
            .transition(.asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .opacity
            ))
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: TurnLabSpacing.xxs) {
                HStack(spacing: TurnLabSpacing.xs) {
                    Text("👋")
                        .font(.title2)
                    Text("Welcome Back!")
                        .font(TurnLabTypography.headline)
                        .foregroundStyle(TurnLabColors.textPrimary)
                }

                if let lastVisit = lastVisit {
                    Text("Last session: \(timeAgoText(from: lastVisit))")
                        .font(TurnLabTypography.caption)
                        .foregroundStyle(TurnLabColors.textSecondary)
                }
            }

            Spacer()

            Button(action: dismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(TurnLabColors.textTertiary)
            }
        }
    }

    // MARK: - Progress Summary

    private var progressSummary: some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.sm) {
            Text("Since your last session:")
                .font(TurnLabTypography.caption)
                .fontWeight(.medium)
                .foregroundStyle(TurnLabColors.textSecondary)

            HStack(spacing: TurnLabSpacing.sm) {
                // Focus skill indicator
                if let skillName = focusSkillName {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Still working on", systemImage: "target")
                            .font(.caption2)
                            .foregroundStyle(TurnLabColors.textTertiary)

                        Text(skillName)
                            .font(TurnLabTypography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(TurnLabColors.textPrimary)
                    }
                    .padding(TurnLabSpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall)
                            .fill(Color.accentColor.opacity(0.08))
                    )
                }

                // Rating indicator
                if let rating = currentRating, rating != .notAssessed {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("You were", systemImage: "chart.bar.fill")
                            .font(.caption2)
                            .foregroundStyle(TurnLabColors.textTertiary)

                        HStack(spacing: 4) {
                            Image(systemName: rating.iconName)
                                .foregroundStyle(rating.color)
                            Text(rating.encouragingName)
                                .font(TurnLabTypography.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(rating.color)
                        }
                    }
                    .padding(TurnLabSpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall)
                            .fill(rating.color.opacity(0.08))
                    )
                }
            }

            // Encouragement message
            if let rating = currentRating, rating != .mastered {
                Text(encouragementMessage(for: rating))
                    .font(TurnLabTypography.caption)
                    .foregroundStyle(TurnLabColors.textSecondary)
                    .padding(.top, TurnLabSpacing.xxs)
            }
        }
    }

    // MARK: - Action Section

    private var actionSection: some View {
        HStack(spacing: TurnLabSpacing.sm) {
            Button(action: {
                onContinue()
                dismiss()
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                    Text("Continue Where I Left Off")
                }
                .font(TurnLabTypography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, TurnLabSpacing.sm)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall))
            }
        }
    }

    // MARK: - Helpers

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }

    private func timeAgoText(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour], from: date, to: now)

        if let days = components.day, days > 0 {
            if days == 1 {
                return "yesterday"
            } else if days < 7 {
                return "\(days) days ago"
            } else if days < 14 {
                return "about a week ago"
            } else if days < 30 {
                return "\(days / 7) weeks ago"
            } else if days < 60 {
                return "about a month ago"
            } else {
                return "\(days / 30) months ago"
            }
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "an hour ago" : "\(hours) hours ago"
        } else {
            return "just now"
        }
    }

    private func encouragementMessage(for rating: Rating) -> String {
        switch rating {
        case .notAssessed:
            return "Ready to start your assessment?"
        case .needsWork:
            return "Every run is practice. Ready to build your foundation?"
        case .developing:
            return "You're making progress! Ready to keep growing?"
        case .confident:
            return "You're almost there! Ready to push for mastery?"
        case .mastered:
            return "Great work! Time for a new challenge?"
        }
    }
}

#Preview("With Focus Skill") {
    WelcomeBackCard(
        lastVisit: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
        focusSkillName: "Parallel Turns",
        currentRating: .developing,
        onContinue: {},
        onDismiss: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Long Absence") {
    WelcomeBackCard(
        lastVisit: Calendar.current.date(byAdding: .day, value: -21, to: Date()),
        focusSkillName: "Hockey Stops",
        currentRating: .needsWork,
        onContinue: {},
        onDismiss: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("No Focus Skill") {
    WelcomeBackCard(
        lastVisit: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
        focusSkillName: nil,
        currentRating: nil,
        onContinue: {},
        onDismiss: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
