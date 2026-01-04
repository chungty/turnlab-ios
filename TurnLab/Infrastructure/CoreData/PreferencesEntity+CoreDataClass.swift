import Foundation
import CoreData

/// Core Data entity for user preferences.
@objc(PreferencesEntity)
public class PreferencesEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var isPremiumUnlocked: Bool
    @NSManaged public var premiumUnlockedAt: Date?
    @NSManaged public var notificationsEnabled: Bool
    @NSManaged public var highContrastMode: Bool
    @NSManaged public var quizResultData: Data?

    // Relationships
    @NSManaged public var user: UserEntity?

    // MARK: - Quiz Result Encoding/Decoding
    var quizResult: QuizResult? {
        get {
            guard let data = quizResultData else { return nil }
            return try? JSONDecoder().decode(QuizResult.self, from: data)
        }
        set {
            quizResultData = try? JSONEncoder().encode(newValue)
        }
    }
}

// MARK: - Fetch Requests
extension PreferencesEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PreferencesEntity> {
        NSFetchRequest<PreferencesEntity>(entityName: "PreferencesEntity")
    }
}
