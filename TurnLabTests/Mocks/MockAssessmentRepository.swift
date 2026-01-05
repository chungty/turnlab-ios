import Foundation
@testable import TurnLab

/// Mock implementation of AssessmentRepositoryProtocol for testing.
final class MockAssessmentRepository: AssessmentRepositoryProtocol {
    // MARK: - Configuration

    var assessments: [AssessmentEntity] = []
    var skillRatings: [String: Rating] = [:]

    // MARK: - Call Tracking

    private(set) var saveAssessmentCallCount = 0
    private(set) var getAssessmentsCallCount = 0
    private(set) var getBestRatingCallCount = 0

    // MARK: - AssessmentRepositoryProtocol

    func saveAssessment(
        skillId: String,
        context: TerrainContext,
        rating: Rating,
        notes: String?
    ) async -> AssessmentEntity {
        saveAssessmentCallCount += 1
        // Note: Cannot create real AssessmentEntity without Core Data context
        fatalError("MockAssessmentRepository.saveAssessment() needs proper Core Data stack")
    }

    func getAssessments(for skillId: String) async -> [AssessmentEntity] {
        getAssessmentsCallCount += 1
        return assessments.filter { $0.skillId == skillId }
    }

    func getLatestAssessment(for skillId: String, context: TerrainContext) async -> AssessmentEntity? {
        return assessments
            .filter { $0.skillId == skillId }
            .sorted { $0.date ?? Date.distantPast > $1.date ?? Date.distantPast }
            .first
    }

    func getBestRating(for skillId: String) async -> Rating {
        getBestRatingCallCount += 1
        return skillRatings[skillId] ?? .notAssessed
    }

    func getAllAssessments() async -> [AssessmentEntity] {
        return assessments
    }

    func getAssessmentCounts() async -> [Rating: Int] {
        var counts: [Rating: Int] = [:]
        for rating in Rating.allCases {
            counts[rating] = 0
        }
        for (_, rating) in skillRatings {
            counts[rating, default: 0] += 1
        }
        return counts
    }

    func getRecentAssessments(days: Int) async -> [AssessmentEntity] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date.distantPast
        return assessments.filter { ($0.date ?? Date.distantPast) > cutoff }
    }

    func deleteAssessment(_ assessment: AssessmentEntity) async {
        // No-op for mock
    }

    func getSkillRatingSummary() async -> [String: Rating] {
        return skillRatings
    }

    // MARK: - Test Helpers

    func reset() {
        assessments = []
        skillRatings = [:]
        saveAssessmentCallCount = 0
        getAssessmentsCallCount = 0
        getBestRatingCallCount = 0
    }

    /// Configure a rating for a specific skill
    func setRating(_ rating: Rating, for skillId: String) {
        skillRatings[skillId] = rating
    }
}
