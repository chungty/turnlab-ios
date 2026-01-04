import Foundation

/// Type-safe navigation routes for the app.
enum Route: Hashable {
    // Skill navigation
    case skillDetail(skillId: String)
    case skillBrowser
    case levelBrowser(level: SkillLevel)
    case domainBrowser(domain: SkillDomain)

    // Assessment
    case assessment(skillId: String)
    case assessmentHistory(skillId: String)

    // Profile
    case profile

    // Settings
    case settings
    case premium

    // Onboarding
    case onboarding
}

/// Tab destinations for the main tab bar.
enum Tab: Hashable, CaseIterable {
    case home
    case skills
    case profile
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .skills: return "Skills"
        case .profile: return "Profile"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .skills: return "square.grid.2x2.fill"
        case .profile: return "person.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
