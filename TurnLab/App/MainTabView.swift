import SwiftUI

/// Main tab bar container for the app.
struct MainTabView: View {
    @EnvironmentObject private var router: NavigationRouter
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var diContainer: DIContainer

    var body: some View {
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
            NavigationStack {
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
                SettingsView(viewModel: diContainer.makeSettingsViewModel())
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
                onSelectSkill: { _ in }
            )

        case .domainBrowser(let domain):
            DomainBasedBrowserView(
                skillsByDomain: [domain: diContainer.contentManager.skills(forDomain: domain)],
                rating: { _ in .notAssessed },
                isLocked: { _ in false },
                onSelectSkill: { _ in }
            )

        case .assessment(let skillId):
            AssessmentInputView(skillId: skillId)

        case .assessmentHistory:
            // AssessmentHistoryView requires assessments array - would need to load async
            EmptyStateView(
                icon: "clock.arrow.circlepath",
                title: "History",
                message: "Assessment history coming soon."
            )

        case .profile:
            ProfileView(viewModel: diContainer.makeProfileViewModel())

        case .settings:
            SettingsView(viewModel: diContainer.makeSettingsViewModel())

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

        case .assessment(let skillId):
            NavigationStack {
                AssessmentInputView(skillId: skillId)
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
