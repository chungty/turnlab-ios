import SwiftUI

/// Main tab bar container for the app.
struct MainTabView: View {
    @EnvironmentObject private var router: NavigationRouter
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var diContainer: DIContainer

    @State private var showCoachChat = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            mainContent

            // Coach Floating Action Button
            if APIKeys.isAIEnabled {
                CoachFAB(isPresented: $showCoachChat, pulse: false)
                    .padding(.trailing, 20)
                    .padding(.bottom, 100) // Above tab bar
            }
        }
        .sheet(isPresented: $showCoachChat) {
            CoachChatView(viewModel: diContainer.makeCoachViewModel())
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        TabView(selection: $router.selectedTab) {
            // Home Tab
            NavigationStack(path: $router.path) {
                HomeView(viewModel: diContainer.makeHomeViewModel())
                    .navigationDestination(for: Route.self) { route in
                        destinationView(for: route)
                    }
            }
            .tabItem {
                Label(Tab.home.title, systemImage: Tab.home.icon)
            }
            .tag(Tab.home)

            // Skills Tab
            NavigationStack(path: $router.skillsPath) {
                SkillBrowserView(viewModel: diContainer.makeSkillBrowserViewModel())
                    .navigationDestination(for: Route.self) { route in
                        destinationView(for: route)
                    }
            }
            .tabItem {
                Label(Tab.skills.title, systemImage: Tab.skills.icon)
            }
            .tag(Tab.skills)

            // Profile Tab
            NavigationStack {
                ProfileView(viewModel: diContainer.makeProfileViewModel())
                    .navigationDestination(for: Route.self) { route in
                        destinationView(for: route)
                    }
            }
            .tabItem {
                Label(Tab.profile.title, systemImage: Tab.profile.icon)
            }
            .tag(Tab.profile)

            // Settings Tab
            NavigationStack {
                SettingsView(
                    viewModel: diContainer.makeSettingsViewModel(),
                    contentManager: diContainer.contentManager
                )
                    .navigationDestination(for: Route.self) { route in
                        destinationView(for: route)
                    }
            }
            .tabItem {
                Label(Tab.settings.title, systemImage: Tab.settings.icon)
            }
            .tag(Tab.settings)
        }
        .tint(Color.accentColor)
        .sheet(item: $router.presentedSheet) { sheet in
            sheetView(for: sheet)
        }
        .accessibilityIdentifier("main_tab_view")
    }

    // MARK: - Navigation Helpers

    /// Navigates to a skill detail view, using the appropriate navigation path based on current tab.
    private func navigateToSkillDetail(_ skillId: String) {
        let route = Route.skillDetail(skillId: skillId)
        switch router.selectedTab {
        case .home:
            router.path.append(route)
        case .skills:
            router.skillsPath.append(route)
        default:
            // For other tabs, switch to skills tab and navigate there
            router.selectedTab = .skills
            router.skillsPath.append(route)
        }
    }

    // MARK: - Destination Builder

    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .skillDetail(let skillId):
            SkillDetailView(
                viewModel: diContainer.makeSkillDetailViewModel(skillId: skillId)
            )

        case .skillBrowser:
            SkillBrowserView(viewModel: diContainer.makeSkillBrowserViewModel())

        case .levelBrowser(let level):
            LevelBasedBrowserView(
                skillsByLevel: [level: diContainer.contentManager.skills(forLevel: level)],
                rating: { _ in .notAssessed },
                isLocked: { _ in false },
                onSelectSkill: { skill in
                    navigateToSkillDetail(skill.id)
                }
            )

        case .domainBrowser(let domain):
            DomainBasedBrowserView(
                skillsByDomain: [domain: diContainer.contentManager.skills(forDomain: domain)],
                rating: { _ in .notAssessed },
                isLocked: { _ in false },
                onSelectSkill: { skill in
                    navigateToSkillDetail(skill.id)
                }
            )

        case .assessment(let skillId):
            AssessmentInputView(viewModel: diContainer.makeAssessmentViewModel(skillId: skillId))

        case .profile:
            ProfileView(viewModel: diContainer.makeProfileViewModel())

        case .settings:
            SettingsView(
                viewModel: diContainer.makeSettingsViewModel(),
                contentManager: diContainer.contentManager
            )

        case .premium:
            PremiumPurchaseView(viewModel: diContainer.makeSettingsViewModel())

        case .onboarding:
            OnboardingContainerView(viewModel: diContainer.makeOnboardingViewModel())
        }
    }

    // MARK: - Sheet Builder

    @ViewBuilder
    private func sheetView(for sheet: SheetDestination) -> some View {
        switch sheet {
        case .premium:
            PremiumPurchaseView(viewModel: diContainer.makeSettingsViewModel())

        case .premiumUpsell(let skill):
            ContextualPremiumUpsellView(
                skill: skill,
                viewModel: diContainer.makeSettingsViewModel()
            )

        case .assessment(let skillId):
            NavigationStack {
                AssessmentInputView(viewModel: diContainer.makeAssessmentViewModel(skillId: skillId))
            }
        }
    }
}

#Preview {
    let container = DIContainer.preview
    return MainTabView()
        .environmentObject(NavigationRouter())
        .environmentObject(container.appState)
        .environmentObject(container)
}
