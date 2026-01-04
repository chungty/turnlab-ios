import Foundation
import CoreData

/// Core Data entity for skill assessments.
@objc(AssessmentEntity)
public class AssessmentEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var skillId: String
    @NSManaged public var context: Int16
    @NSManaged public var rating: Int16
    @NSManaged public var date: Date
    @NSManaged public var notes: String?

    // Relationships
    @NSManaged public var user: UserEntity?

    // MARK: - Convenience
    var terrainContext: TerrainContext? {
        TerrainContext.allCases.first { $0.hashValue == Int(context) }
    }

    var ratingValue: Rating {
        get { Rating(rawValue: Int(rating)) ?? .notAssessed }
        set { rating = Int16(newValue.rawValue) }
    }
}

// MARK: - Fetch Requests
extension AssessmentEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AssessmentEntity> {
        NSFetchRequest<AssessmentEntity>(entityName: "AssessmentEntity")
    }

    static func fetchForSkill(
        _ skillId: String,
        in context: NSManagedObjectContext
    ) -> [AssessmentEntity] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "skillId == %@", skillId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AssessmentEntity.date, ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    static func fetchLatestForSkill(
        _ skillId: String,
        terrainContext: TerrainContext,
        in context: NSManagedObjectContext
    ) -> AssessmentEntity? {
        let request = fetchRequest()
        request.predicate = NSPredicate(
            format: "skillId == %@ AND context == %d",
            skillId,
            terrainContext.hashValue
        )
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AssessmentEntity.date, ascending: false)]
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    static func fetchAllAssessments(in context: NSManagedObjectContext) -> [AssessmentEntity] {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AssessmentEntity.date, ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
}

// MARK: - Creation
extension AssessmentEntity {
    static func create(
        in context: NSManagedObjectContext,
        skillId: String,
        terrainContext: TerrainContext,
        rating: Rating,
        notes: String? = nil,
        user: UserEntity? = nil
    ) -> AssessmentEntity {
        let assessment = AssessmentEntity(context: context)
        assessment.id = UUID()
        assessment.skillId = skillId
        assessment.context = Int16(terrainContext.hashValue)
        assessment.rating = Int16(rating.rawValue)
        assessment.date = Date()
        assessment.notes = notes
        assessment.user = user
        return assessment
    }
}
