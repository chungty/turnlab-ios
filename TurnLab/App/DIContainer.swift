import SwiftUI
import CoreData

/// Dependency injection container for Turn Lab.
/// Provides concrete implementations of all protocols.
@MainActor
final class DIContainer: ObservableObject {
    // MARK: - Core Services
    let coreDataStack: CoreDataStack
    let contentManager: ContentManager

    // MARK: - Repositories
    let skillRepository: SkillRepositoryProtocol
    let userRepository: UserRepositoryProtocol
    let assessmentRepository: AssessmentRepositoryProtocol

    // MARK: - Services
    let progressionService: ProgressionService
    let premiumManager: PremiumManager
    let purchaseService: PurchaseService

    // MARK: - Shared State
    let appState: AppState

    // MARK: - Initialization
    init(inMemory: Bool = false) {
        // Initialize Core Data
        self.coreDataStack = CoreDataStack(inMemory: inMemory)

        // Initialize Content Manager
        self.contentManager = ContentManager()

        // Initialize Repositories
        self.skillRepository = SkillRepository(contentManager: contentManager)
        self.userRepository = UserRepository(coreDataStack: coreDataStack)
        self.assessmentRepository = AssessmentRepository(coreDataStack: coreDataStack)

        // Initialize Services
        self.purchaseService = PurchaseService()
        self.premiumManager = PremiumManager(
            userRepository: userRepository,
            purchaseService: purchaseService
        )
        self.progressionService = ProgressionService(
            skillRepository: skillRepository,
            assessmentRepository: assessmentRepository
        )

        // Initialize App State from persisted data
        self.appState = AppState()

        // Load initial state
        Task {
            await loadInitialState()
        }
    }

    // MARK: - State Loading
    private func loadInitialState() async {
        // Load user data
        if let user = await userRepository.getCurrentUser() {
            appState.isOnboardingComplete = true
            appState.currentUserLevel = SkillLevel(rawValue: Int(user.currentLevel)) ?? .beginner
            appState.focusSkillId = user.focusSkillId
        }

        // Load premium status
        appState.isPremiumUnlocked = await premiumManager.checkPremiumStatus()

        // Load content
        await contentManager.loadContent()
    }

    // MARK: - Factory Methods
    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(
            contentManager: contentManager,
            userRepository: userRepository,
            appState: appState
        )
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            skillRepository: skillRepository,
            assessmentRepository: assessmentRepository,
            progressionService: progressionService,
            appState: appState
        )
    }

    func makeSkillBrowserViewModel() -> SkillBrowserViewModel {
        SkillBrowserViewModel(
            skillRepository: skillRepository,
            assessmentRepository: assessmentRepository,
            appState: appState
        )
    }

    func makeSkillDetailViewModel(skillId: String) -> SkillDetailViewModel {
        SkillDetailViewModel(
            skillId: skillId,
            skillRepository: skillRepository,
            assessmentRepository: assessmentRepository,
            appState: appState
        )
    }

    func makeAssessmentViewModel(skillId: String) -> AssessmentViewModel {
        AssessmentViewModel(
            skillId: skillId,
            skillRepository: skillRepository,
            assessmentRepository: assessmentRepository,
            progressionService: progressionService
        )
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            userRepository: userRepository,
            assessmentRepository: assessmentRepository,
            progressionService: progressionService,
            appState: appState
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            premiumManager: premiumManager,
            userRepository: userRepository,
            appState: appState
        )
    }
}

// MARK: - Preview Container
extension DIContainer {
    static var preview: DIContainer {
        DIContainer(inMemory: true)
    }
}
