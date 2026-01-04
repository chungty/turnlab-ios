import SwiftUI

/// Root view that handles app-level navigation state.
struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: NavigationRouter
    @EnvironmentObject private var diContainer: DIContainer

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingContainerView(viewModel: diContainer.makeOnboardingViewModel())
            }
        }
        .fullScreenCover(item: $router.presentedFullScreenCover) { cover in
            fullScreenCoverView(for: cover)
        }
        .onOpenURL { url in
            router.handleDeepLink(url)
        }
    }

    // MARK: - Full Screen Cover Builder

    @ViewBuilder
    private func fullScreenCoverView(for cover: FullScreenDestination) -> some View {
        switch cover {
        case .onboarding:
            OnboardingContainerView(viewModel: diContainer.makeOnboardingViewModel())
        }
    }
}

#Preview("Onboarding") {
    @Previewable @StateObject var router = NavigationRouter()
    @Previewable @StateObject var container = DIContainer.preview
    @Previewable @StateObject var appState = AppState()

    RootView()
        .environmentObject(router)
        .environmentObject(appState)
        .environmentObject(container)
        .onAppear { appState.hasCompletedOnboarding = false }
}

#Preview("Main App") {
    @Previewable @StateObject var router = NavigationRouter()
    @Previewable @StateObject var container = DIContainer.preview
    @Previewable @StateObject var appState = AppState()

    RootView()
        .environmentObject(router)
        .environmentObject(appState)
        .environmentObject(container)
        .onAppear { appState.hasCompletedOnboarding = true }
}
