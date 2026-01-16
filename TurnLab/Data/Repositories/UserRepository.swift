import Foundation
import CoreData

/// Implementation of UserRepositoryProtocol using Core Data.
final class UserRepository: UserRepositoryProtocol, @unchecked Sendable {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func getCurrentUser() async -> UserEntity? {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                let user = UserEntity.fetchCurrentUser(in: context)
                continuation.resume(returning: user)
            }
        }
    }

    func createUser(level: SkillLevel) async -> UserEntity {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                let user = UserEntity.create(in: context, level: level)
                self.coreDataStack.save()
                continuation.resume(returning: user)
            }
        }
    }

    func updateUserLevel(_ level: SkillLevel) async {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                if let user = UserEntity.fetchCurrentUser(in: context) {
                    user.skillLevel = level
                    user.updatedAt = Date()
                    self.coreDataStack.save()
                }
                continuation.resume()
            }
        }
    }

    func updateFocusSkill(_ skillId: String?) async {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                if let user = UserEntity.fetchCurrentUser(in: context) {
                    user.focusSkillId = skillId
                    user.updatedAt = Date()
                    self.coreDataStack.save()
                }
                continuation.resume()
            }
        }
    }

    func getPreferences() async -> PreferencesEntity? {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                let user = UserEntity.fetchCurrentUser(in: context)
                continuation.resume(returning: user?.preferences)
            }
        }
    }

    func updatePremiumStatus(unlocked: Bool) async {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                if let user = UserEntity.fetchCurrentUser(in: context),
                   let prefs = user.preferences {
                    prefs.isPremiumUnlocked = unlocked
                    prefs.premiumUnlockedAt = unlocked ? Date() : nil
                    self.coreDataStack.save()
                }
                continuation.resume()
            }
        }
    }

    func updateNotificationPreference(enabled: Bool) async {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                if let user = UserEntity.fetchCurrentUser(in: context),
                   let prefs = user.preferences {
                    prefs.notificationsEnabled = enabled
                    self.coreDataStack.save()
                }
                continuation.resume()
            }
        }
    }

    func saveQuizResult(_ result: QuizResult) async {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                if let user = UserEntity.fetchCurrentUser(in: context),
                   let prefs = user.preferences {
                    prefs.quizResult = result
                    self.coreDataStack.save()
                }
                continuation.resume()
            }
        }
    }

    func isOnboardingComplete() async -> Bool {
        await getCurrentUser() != nil
    }
}
