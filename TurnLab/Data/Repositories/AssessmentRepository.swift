import Foundation
import CoreData

/// Implementation of AssessmentRepositoryProtocol using Core Data.
final class AssessmentRepository: AssessmentRepositoryProtocol, @unchecked Sendable {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func saveAssessment(
        skillId: String,
        context: TerrainContext,
        rating: Rating,
        notes: String?
    ) async -> AssessmentEntity {
        await withCheckedContinuation { continuation in
            let coreContext = coreDataStack.viewContext
            coreContext.perform {
                let user = UserEntity.fetchCurrentUser(in: coreContext)
                let assessment = AssessmentEntity.create(
                    in: coreContext,
                    skillId: skillId,
                    terrainContext: context,
                    rating: rating,
                    notes: notes,
                    user: user
                )
                self.coreDataStack.save()
                continuation.resume(returning: assessment)
            }
        }
    }

    func getAssessments(for skillId: String) async -> [AssessmentEntity] {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                let assessments = AssessmentEntity.fetchForSkill(skillId, in: context)
                continuation.resume(returning: assessments)
            }
        }
    }

    func getLatestAssessment(
        for skillId: String,
        context terrainContext: TerrainContext
    ) async -> AssessmentEntity? {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                let assessment = AssessmentEntity.fetchLatestForSkill(
                    skillId,
                    terrainContext: terrainContext,
                    in: context
                )
                continuation.resume(returning: assessment)
            }
        }
    }

    func getBestRating(for skillId: String) async -> Rating {
        let assessments = await getAssessments(for: skillId)
        return assessments
            .map { $0.ratingValue }
            .max() ?? .notAssessed
    }

    func getAllAssessments() async -> [AssessmentEntity] {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                let assessments = AssessmentEntity.fetchAllAssessments(in: context)
                continuation.resume(returning: assessments)
            }
        }
    }

    func getAssessmentCounts() async -> [Rating: Int] {
        let assessments = await getAllAssessments()
        var counts: [Rating: Int] = [:]
        for rating in Rating.allCases {
            counts[rating] = assessments.filter { $0.ratingValue == rating }.count
        }
        return counts
    }

    func getRecentAssessments(days: Int) async -> [AssessmentEntity] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let allAssessments = await getAllAssessments()
        return allAssessments.filter { $0.date >= cutoffDate }
    }

    func deleteAssessment(_ assessment: AssessmentEntity) async {
        // Capture the objectID which is Sendable, then refetch in the context
        let objectID = assessment.objectID
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                if let toDelete = try? context.existingObject(with: objectID) {
                    context.delete(toDelete)
                    self.coreDataStack.save()
                }
                continuation.resume()
            }
        }
    }

    func getSkillRatingSummary() async -> [String: Rating] {
        let assessments = await getAllAssessments()
        var summary: [String: Rating] = [:]

        // Group by skill and get best rating
        let grouped = Dictionary(grouping: assessments) { $0.skillId }
        for (skillId, skillAssessments) in grouped {
            let bestRating = skillAssessments
                .map { $0.ratingValue }
                .max() ?? .notAssessed
            summary[skillId] = bestRating
        }

        return summary
    }
}
