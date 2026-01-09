import SwiftUI

/// Tips tab content.
struct TipsContentTab: View {
    let tips: [Tip]
    let warnings: [SafetyWarning]

    var body: some View {
        if tips.isEmpty && warnings.isEmpty {
            EmptyStateView(
                icon: "lightbulb",
                title: "No Tips Yet",
                message: "Tips and guidance are coming soon."
            )
        } else {
            VStack(spacing: TurnLabSpacing.md) {
                // Quick reference tips first
                let quickTips = tips.filter { $0.isQuickReference }
                if !quickTips.isEmpty {
                    VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundStyle(.yellow)
                            Text("Quick Reference")
                                .font(TurnLabTypography.headline)
                        }

                        ForEach(quickTips) { tip in
                            TipCard(tip: tip)
                        }
                    }
                }

                // All other tips
                let otherTips = tips.filter { !$0.isQuickReference }
                if !otherTips.isEmpty {
                    VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                        Text("All Tips")
                            .font(TurnLabTypography.headline)

                        ForEach(otherTips) { tip in
                            TipCard(tip: tip)
                        }
                    }
                }

                // Safety warnings
                if !warnings.isEmpty {
                    VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("Safety Notes")
                                .font(TurnLabTypography.headline)
                        }

                        ForEach(warnings) { warning in
                            SafetyWarningCard(warning: warning)
                        }
                    }
                }
            }
        }
    }
}

struct SafetyWarningCard: View {
    let warning: SafetyWarning

    var body: some View {
        HStack(alignment: .top, spacing: TurnLabSpacing.sm) {
            Image(systemName: warning.severity.iconName)
                .foregroundStyle(severityColor)

            VStack(alignment: .leading, spacing: TurnLabSpacing.xxs) {
                Text(warning.title)
                    .font(TurnLabTypography.headline)
                    .foregroundStyle(TurnLabColors.textPrimary)

                Text(warning.content)
                    .font(TurnLabTypography.body)
                    .foregroundStyle(TurnLabColors.textSecondary)

                if !warning.applicableContexts.isEmpty {
                    HStack(spacing: 4) {
                        Text("Applies to:")
                            .font(.caption2)
                            .foregroundStyle(TurnLabColors.textTertiary)
                        ForEach(warning.applicableContexts) { context in
                            Text(context.shortName)
                                .font(.caption2)
                                .foregroundStyle(TurnLabColors.textSecondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(severityColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
    }

    private var severityColor: Color {
        switch warning.severity {
        case .info: return .blue
        case .caution: return .orange
        case .warning: return .red
        case .critical: return .purple
        }
    }
}

#Preview {
    ScrollView {
        TipsContentTab(
            tips: [
                Tip(id: "1", title: "Lazy Susan Feet", content: "Imagine your feet are on a lazy Susan rotating together.", category: .mentalCue, isQuickReference: true),
                Tip(id: "2", title: "Hands Forward", content: "Keep your hands in front as if holding a tray.", category: .bodyPosition, isQuickReference: false)
            ],
            warnings: [
                SafetyWarning(id: "1", title: "Icy Conditions", content: "On ice, focus on edge angle before initiating the turn.", severity: .caution, applicableContexts: [.ice])
            ]
        )
        .padding()
    }
}
