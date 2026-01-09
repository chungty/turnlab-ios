import SwiftUI

/// Detailed view for a single skill.
struct SkillDetailView: View {
    @StateObject private var viewModel: SkillDetailViewModel
    @EnvironmentObject private var diContainer: DIContainer

    init(viewModel: SkillDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 100)
            } else if let skill = viewModel.skill {
                VStack(spacing: 0) {
                    // Hero section
                    SkillHeroSection(
                        skill: skill,
                        rating: viewModel.overallRating,
                        isFocusSkill: viewModel.isFocusSkill,
                        onSetFocus: viewModel.setAsFocusSkill,
                        onRemoveFocus: viewModel.removeFocusSkill
                    )

                    // Assessment section (inline - tap to save directly)
                    AssessmentSection(
                        skill: skill,
                        contextRatings: viewModel.contextRatings,
                        overallRating: viewModel.overallRating,
                        onRatingSelected: { rating in
                            Task { await viewModel.saveInlineAssessment(rating: rating) }
                        },
                        isSaving: viewModel.isSavingAssessment,
                        showSaveSuccess: viewModel.showSaveSuccess
                    )
                    .padding()

                    // Prerequisites warning
                    if !viewModel.prerequisitesMet && !viewModel.prerequisites.isEmpty {
                        PrerequisitesWarning(prerequisites: viewModel.prerequisites)
                            .padding(.horizontal)
                    }

                    // Content tabs
                    ContentTabsSection(
                        selectedTab: $viewModel.selectedContentTab,
                        videos: viewModel.videos,
                        tips: viewModel.tips,
                        drills: viewModel.drills,
                        checklists: viewModel.checklists,
                        warnings: viewModel.warnings
                    )
                    .padding()
                }
            } else {
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "Skill Not Found",
                    message: "This skill could not be loaded."
                )
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(viewModel.skill?.name ?? "Skill")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadData()
        }
        .progressCelebration(
            isPresented: $viewModel.showCelebration,
            skillName: viewModel.skill?.name ?? "",
            previousRating: viewModel.celebrationPreviousRating,
            newRating: viewModel.celebrationNewRating,
            nextChallenge: nextChallengeText
        )
    }

    /// Gets the next milestone description to show in celebration.
    private var nextChallengeText: String? {
        guard let skill = viewModel.skill else { return nil }
        let nextRating = viewModel.celebrationNewRating.nextLevel
        guard let next = nextRating else { return nil }
        let milestone = skill.outcomeMilestones.description(for: next)
        return milestone.isEmpty ? nil : milestone
    }
}

struct PrerequisitesWarning: View {
    let prerequisites: [Skill]

    var body: some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("Prerequisites Recommended")
                    .font(TurnLabTypography.headline)
            }

            Text("Consider working on these skills first:")
                .font(TurnLabTypography.caption)
                .foregroundStyle(TurnLabColors.textSecondary)

            ForEach(prerequisites) { prereq in
                HStack {
                    LevelBadge(level: prereq.level, size: .small)
                    Text(prereq.name)
                        .font(TurnLabTypography.body)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
    }
}

struct ContentTabsSection: View {
    @Binding var selectedTab: SkillDetailViewModel.ContentTab
    let videos: [VideoReference]
    let tips: [Tip]
    let drills: [Drill]
    let checklists: [Checklist]
    let warnings: [SafetyWarning]

    var body: some View {
        VStack(spacing: TurnLabSpacing.md) {
            // Tab picker
            Picker("Content", selection: $selectedTab) {
                ForEach(SkillDetailViewModel.ContentTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)

            // Content based on selected tab
            switch selectedTab {
            case .videos:
                VideoContentTab(videos: videos)
            case .tips:
                TipsContentTab(tips: tips, warnings: warnings)
            case .drills:
                DrillsContentTab(drills: drills, checklists: checklists)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SkillDetailView(
            viewModel: SkillDetailViewModel(
                skillId: "test",
                skillRepository: SkillRepository(contentManager: ContentManager()),
                assessmentRepository: AssessmentRepository(coreDataStack: .preview),
                appState: AppState()
            )
        )
    }
}
