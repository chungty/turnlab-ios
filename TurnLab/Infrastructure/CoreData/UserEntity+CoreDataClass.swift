import Foundation
import CoreData

/// Core Data entity for user profile data.
@objc(UserEntity)
public class UserEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var currentLevel: Int16
    @NSManaged public var focusSkillId: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // Relationships
    @NSManaged public var preferences: PreferencesEntity?
    @NSManaged public var assessments: NSSet?

    // MARK: - Convenience
    var skillLevel: SkillLevel {
        get { SkillLevel(rawValue: Int(currentLevel)) ?? .beginner }
        set { currentLevel = Int16(newValue.order) }
    }
}

// MARK: - Fetch Requests
extension UserEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    static func fetchCurrentUser(in context: NSManagedObjectContext) -> UserEntity? {
        let request = fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(keyPath: \UserEntity.createdAt, ascending: true)]
        return try? context.fetch(request).first
    }
}

// MARK: - Creation
extension UserEntity {
    static func create(
        in context: NSManagedObjectContext,
        level: SkillLevel = .beginner
    ) -> UserEntity {
        let user = UserEntity(context: context)
        user.id = UUID()
        user.currentLevel = Int16(level.order)
        user.createdAt = Date()
        user.updatedAt = Date()

        // Create preferences
        let prefs = PreferencesEntity(context: context)
        prefs.id = UUID()
        prefs.isPremiumUnlocked = false
        prefs.notificationsEnabled = true
        user.preferences = prefs

        return user
    }
}
