import Foundation

/// Protocol for assessment data persistence.
protocol AssessmentRepositoryProtocol {
    /// Save a new assessment
    func saveAssessment(
        skillId: String,
        context: TerrainContext,
        rating: Rating,
        notes: String?
    ) async -> AssessmentEntity

    /// Get all assessments for a skill
    func getAssessments(for skillId: String) async -> [AssessmentEntity]

    /// Get the latest assessment for a skill in a specific context
    func getLatestAssessment(
        for skillId: String,
        context: TerrainContext
    ) async -> AssessmentEntity?

    /// Get the best rating achieved for a skill across all contexts
    func getBestRating(for skillId: String) async -> Rating

    /// Get all assessments
    func getAllAssessments() async -> [AssessmentEntity]

    /// Get assessment count by rating
    func getAssessmentCounts() async -> [Rating: Int]

    /// Get assessments from the last N days
    func getRecentAssessments(days: Int) async -> [AssessmentEntity]

    /// Delete an assessment
    func deleteAssessment(_ assessment: AssessmentEntity) async

    /// Get a summary of ratings per skill (for progression calculation)
    func getSkillRatingSummary() async -> [String: Rating]
}
