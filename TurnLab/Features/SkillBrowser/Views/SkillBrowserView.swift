import SwiftUI

/// Main skill browser view with filtering and view mode switching.
struct SkillBrowserView: View {
    @StateObject private var viewModel: SkillBrowserViewModel
    @EnvironmentObject private var container: DIContainer
    @EnvironmentObject private var router: NavigationRouter

    init(viewModel: SkillBrowserViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            // View mode picker
            Picker("View Mode", selection: $viewModel.viewMode) {
                ForEach(SkillBrowserViewModel.ViewMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Content
            if viewModel.isContentLoading || viewModel.isLoading {
                Spacer()
                VStack(spacing: TurnLabSpacing.md) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading skills...")
                        .font(TurnLabTypography.body)
                        .foregroundColor(TurnLabColors.textSecondary)
                }
                Spacer()
            } else if viewModel.filteredSkills.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No Skills Found",
                    message: "Try adjusting your search or filters.",
                    actionTitle: "Clear Filters",
                    action: { viewModel.clearFilters() }
                )
            } else {
                ScrollView {
                    switch viewModel.viewMode {
                    case .byLevel:
                        LevelBasedBrowserView(
                            skillsByLevel: viewModel.skillsByLevel,
                            rating: viewModel.rating,
                            isLocked: viewModel.isLocked,
                            onSelectSkill: navigateToSkill
                        )
                    case .byDomain:
                        DomainBasedBrowserView(
                            skillsByDomain: viewModel.skillsByDomain,
                            rating: viewModel.rating,
                            isLocked: viewModel.isLocked,
                            onSelectSkill: navigateToSkill
                        )
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Skills")
        .searchable(text: $viewModel.searchQuery, prompt: "Search skills")
        .task {
            await viewModel.loadData()
        }
        .refreshable {
            await viewModel.loadData()
        }
    }

    private func navigateToSkill(_ skill: Skill) {
        if viewModel.canAccess(skill) {
            router.skillsPath.append(Route.skillDetail(skillId: skill.id))
        } else {
            // Show contextual paywall instead of silent failure
            router.presentSheet(.premiumUpsell(skill: skill))
        }
    }
}

#Preview {
    let contentManager = ContentManager()
    return NavigationStack {
        SkillBrowserView(
            viewModel: SkillBrowserViewModel(
                skillRepository: SkillRepository(contentManager: contentManager),
                assessmentRepository: AssessmentRepository(coreDataStack: .preview),
                appState: AppState(),
                contentManager: contentManager
            )
        )
    }
    .environmentObject(NavigationRouter())
}
