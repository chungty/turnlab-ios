import SwiftUI

/// Centralized navigation state management.
@MainActor
final class NavigationRouter: ObservableObject {
    /// Navigation path for programmatic navigation.
    @Published var path = NavigationPath()

    /// Currently selected tab.
    @Published var selectedTab: Tab = .home

    /// Sheet presentation state.
    @Published var presentedSheet: SheetDestination?

    /// Full screen cover state.
    @Published var presentedFullScreenCover: FullScreenDestination?

    // MARK: - Navigation Methods

    /// Navigate to a route by pushing it onto the navigation stack.
    func navigate(to route: Route) {
        path.append(route)
    }

    /// Pop the current view from the navigation stack.
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Pop to the root of the navigation stack.
    func popToRoot() {
        path = NavigationPath()
    }

    /// Switch to a specific tab.
    func switchTab(to tab: Tab) {
        selectedTab = tab
    }

    /// Present a sheet.
    func presentSheet(_ sheet: SheetDestination) {
        presentedSheet = sheet
    }

    /// Dismiss the current sheet.
    func dismissSheet() {
        presentedSheet = nil
    }

    /// Present a full screen cover.
    func presentFullScreenCover(_ cover: FullScreenDestination) {
        presentedFullScreenCover = cover
    }

    /// Dismiss the full screen cover.
    func dismissFullScreenCover() {
        presentedFullScreenCover = nil
    }

    // MARK: - Deep Link Handling

    /// Handle a deep link URL.
    func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            return
        }

        switch host {
        case "skill":
            if let skillId = components.queryItems?.first(where: { $0.name == "id" })?.value {
                switchTab(to: .skills)
                navigate(to: .skillDetail(skillId: skillId))
            }

        case "profile":
            switchTab(to: .profile)

        case "settings":
            switchTab(to: .settings)

        case "premium":
            switchTab(to: .settings)
            presentSheet(.premium)

        default:
            break
        }
    }
}

// MARK: - Sheet Destinations

enum SheetDestination: Identifiable {
    case premium
    case assessment(skillId: String)

    var id: String {
        switch self {
        case .premium: return "premium"
        case .assessment(let skillId): return "assessment-\(skillId)"
        }
    }
}

// MARK: - Full Screen Destinations

enum FullScreenDestination: Identifiable {
    case onboarding

    var id: String {
        switch self {
        case .onboarding: return "onboarding"
        }
    }
}
