import SwiftUI

/// Contextual premium upsell shown when user taps a locked skill.
/// Shows specific skill info and content counts to highlight value.
struct ContextualPremiumUpsellView: View {
    let skill: Skill
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TurnLabSpacing.xl) {
                    // Skill header
                    skillHeader

                    // Content preview
                    contentPreview

                    // Value proposition
                    valueProposition

                    Spacer(minLength: TurnLabSpacing.xl)

                    // Purchase CTA
                    purchaseSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Unlock \(skill.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    // MARK: - Skill Header

    private var skillHeader: some View {
        VStack(spacing: TurnLabSpacing.md) {
            // Lock icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "lock.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.accentColor)
            }

            // Skill info
            VStack(spacing: TurnLabSpacing.xs) {
                Text(skill.name)
                    .font(TurnLabTypography.title2)
                    .foregroundStyle(TurnLabColors.textPrimary)
                    .multilineTextAlignment(.center)

                HStack(spacing: TurnLabSpacing.sm) {
                    LevelBadge(level: skill.level)

                    ForEach(skill.domains.prefix(2), id: \.self) { domain in
                        Text(domain.shortName)
                            .font(.caption)
                            .foregroundStyle(TurnLabColors.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Locked skill: \(skill.name), \(skill.level.displayName) level")
    }

    // MARK: - Content Preview

    private var contentPreview: some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.md) {
            Text("What You'll Get")
                .font(TurnLabTypography.headline)
                .foregroundStyle(TurnLabColors.textPrimary)

            HStack(spacing: TurnLabSpacing.md) {
                ContentCountCard(
                    icon: "lightbulb.fill",
                    count: skill.content.tips.count,
                    label: "Tips",
                    color: .yellow
                )

                ContentCountCard(
                    icon: "figure.skiing.downhill",
                    count: skill.content.drills.count,
                    label: "Drills",
                    color: .blue
                )

                ContentCountCard(
                    icon: "play.rectangle.fill",
                    count: skill.content.videos.count,
                    label: "Videos",
                    color: .red
                )
            }

            // Mental cue highlight
            if let firstMentalCue = skill.content.mentalCues.first {
                VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(Color.purple)
                        Text("Mental Cue Preview")
                            .font(TurnLabTypography.caption)
                            .foregroundStyle(TurnLabColors.textSecondary)
                    }

                    Text("\"\(firstMentalCue.title)\"")
                        .font(TurnLabTypography.body)
                        .italic()
                        .foregroundStyle(TurnLabColors.textPrimary)
                        .lineLimit(2)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusLarge))
    }

    // MARK: - Value Proposition

    private var valueProposition: some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.sm) {
            Text("Premium Includes")
                .font(TurnLabTypography.headline)
                .foregroundStyle(TurnLabColors.textPrimary)

            VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                BenefitRow(icon: "checkmark.circle.fill", text: "All skill levels unlocked")
                BenefitRow(icon: "checkmark.circle.fill", text: "Mental cues for every skill")
                BenefitRow(icon: "checkmark.circle.fill", text: "On-mountain drills & checklists")
                BenefitRow(icon: "checkmark.circle.fill", text: "Home screen widget")
                BenefitRow(icon: "checkmark.circle.fill", text: "One-time purchase, no subscription")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusLarge))
    }

    // MARK: - Purchase Section

    private var purchaseSection: some View {
        VStack(spacing: TurnLabSpacing.sm) {
            if let error = viewModel.purchaseError {
                Text(error)
                    .font(TurnLabTypography.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            PrimaryButton(
                title: "Unlock Premium \(viewModel.premiumPrice)",
                icon: "lock.open.fill",
                isLoading: viewModel.isLoadingPurchase
            ) {
                Task {
                    await viewModel.purchasePremium()
                    if viewModel.isPremium {
                        dismiss()
                    }
                }
            }
            .accessibilityHint("Double tap to purchase premium and unlock this skill")

            Button("Restore Purchases") {
                Task {
                    await viewModel.restorePurchases()
                    if viewModel.isPremium {
                        dismiss()
                    }
                }
            }
            .font(TurnLabTypography.caption)
            .foregroundStyle(TurnLabColors.textSecondary)

            Text("Payment will be charged to your Apple ID account.")
                .font(.caption2)
                .foregroundStyle(TurnLabColors.textTertiary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Supporting Views

private struct ContentCountCard: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: TurnLabSpacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text("\(count)")
                .font(TurnLabTypography.title3)
                .fontWeight(.bold)
                .foregroundStyle(TurnLabColors.textPrimary)

            Text(label)
                .font(.caption)
                .foregroundStyle(TurnLabColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(count) \(label)")
    }
}

private struct BenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: TurnLabSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .font(.body)

            Text(text)
                .font(TurnLabTypography.body)
                .foregroundStyle(TurnLabColors.textPrimary)

            Spacer()
        }
    }
}

#Preview {
    ContextualPremiumUpsellView(
        skill: Skill(
            id: "preview-skill",
            name: "Parallel Turns",
            level: .intermediate,
            domains: [.rotaryMovements, .pressureManagement],
            prerequisites: [],
            summary: "Link turns with parallel skis throughout.",
            outcomeMilestones: Skill.OutcomeMilestones(
                needsWork: "Skis frequently cross",
                developing: "Can do on easy terrain",
                confident: "Links turns naturally on blues",
                mastered: "Controls turn shape on any groomed"
            ),
            assessmentContexts: [.groomedBlue, .groomedBlack],
            content: SkillContent(
                videos: [
                    VideoReference(id: "1", title: "Parallel Fundamentals", youtubeId: "abc123", channelName: "Stomp It Tutorials", duration: 330, isPrimary: true)
                ],
                tips: [
                    Tip(id: "1", title: "Lazy Susan Feet", content: "Imagine feet on rotating platform", category: .mentalCue, isQuickReference: true),
                    Tip(id: "2", title: "Hands Forward", content: "Keep hands visible", category: .bodyPosition, isQuickReference: false)
                ],
                drills: [
                    Drill(id: "1", title: "Traverse Practice", overview: "Practice from traverse", steps: [], difficulty: .medium, recommendedTerrain: [], estimatedReps: "10 each way")
                ],
                checklists: [],
                warnings: []
            )
        ),
        viewModel: SettingsViewModel(
            premiumManager: PremiumManager(
                userRepository: UserRepository(coreDataStack: .preview),
                purchaseService: PurchaseService()
            ),
            userRepository: UserRepository(coreDataStack: .preview),
            appState: AppState()
        )
    )
}
