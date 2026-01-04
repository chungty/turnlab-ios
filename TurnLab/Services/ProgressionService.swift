import Foundation

/// Service for calculating skill progression and level advancement.
final class ProgressionService {
    private let skillRepository: SkillRepositoryProtocol
    private let assessmentRepository: AssessmentRepositoryProtocol

    init(
        skillRepository: SkillRepositoryProtocol,
        assessmentRepository: AssessmentRepositoryProtocol
    ) {
        self.skillRepository = skillRepository
        self.assessmentRepository = assessmentRepository
    }

    // MARK: - Level Progression

    /// Calculate progress percentage toward next level
    func progressTowardNextLevel(currentLevel: SkillLevel) async -> Double {
        let skills = await skillRepository.getSkills(for: currentLevel)
        let ratingSummary = await assessmentRepository.getSkillRatingSummary()

        guard !skills.isEmpty else { return 0 }

        let skillsWithConfidentRating = skills.filter { skill in
            guard let rating = ratingSummary[skill.id] else { return false }
            return rating.countsTowardProgression
        }.count

        return Double(skillsWithConfidentRating) / Double(skills.count)
    }

    /// Check if user is ready to advance to the next level
    func canAdvanceToNextLevel(currentLevel: SkillLevel) async -> Bool {
        let progress = await progressTowardNextLevel(currentLevel: currentLevel)
        return progress >= SkillLevel.unlockThreshold
    }

    /// Get the next level (nil if at expert)
    func nextLevel(from current: SkillLevel) -> SkillLevel? {
        switch current {
        case .beginner: return .novice
        case .novice: return .intermediate
        case .intermediate: return .expert
        case .expert: return nil
        }
    }

    // MARK: - Skill Progress

    /// Get overall rating for a skill (best rating across all contexts)
    func overallRating(for skillId: String) async -> Rating {
        await assessmentRepository.getBestRating(for: skillId)
    }

    /// Calculate skill completeness (how many contexts are rated)
    func skillCompleteness(for skill: Skill) async -> Double {
        let assessments = await assessmentRepository.getAssessments(for: skill.id)
        let assessedContexts = Set(assessments.compactMap { $0.terrainContext })
        let totalContexts = skill.assessmentContexts.count
        guard totalContexts > 0 else { return 0 }
        return Double(assessedContexts.count) / Double(totalContexts)
    }

    // MARK: - Recommendations

    /// Get suggested skills to focus on
    func suggestedSkills(
        currentLevel: SkillLevel,
        limit: Int = 3
    ) async -> [Skill] {
        let skills = await skillRepository.getSkills(for: currentLevel)
        let ratingSummary = await assessmentRepository.getSkillRatingSummary()

        // Prioritize unassessed, then needs work, then developing
        let sorted = skills.sorted { skill1, skill2 in
            let rating1 = ratingSummary[skill1.id] ?? .notAssessed
            let rating2 = ratingSummary[skill2.id] ?? .notAssessed
            return rating1 < rating2
        }

        return Array(sorted.prefix(limit))
    }

    /// Check if prerequisites are met for a skill
    func prerequisitesMet(for skill: Skill) async -> Bool {
        guard !skill.prerequisites.isEmpty else { return true }

        let ratingSummary = await assessmentRepository.getSkillRatingSummary()

        return skill.prerequisites.allSatisfy { prereqId in
            guard let rating = ratingSummary[prereqId] else { return false }
            return rating >= .developing
        }
    }

    // MARK: - Statistics

    /// Get overall statistics
    func getStatistics() async -> ProgressStatistics {
        let allSkills = await skillRepository.getAllSkills()
        let ratingSummary = await assessmentRepository.getSkillRatingSummary()
        let recentAssessments = await assessmentRepository.getRecentAssessments(days: 30)

        let assessedCount = ratingSummary.count
        let confidentCount = ratingSummary.values.filter { $0.countsTowardProgression }.count

        return ProgressStatistics(
            totalSkills: allSkills.count,
            assessedSkills: assessedCount,
            confidentSkills: confidentCount,
            recentAssessments: recentAssessments.count,
            completionPercentage: allSkills.isEmpty ? 0 : Double(confidentCount) / Double(allSkills.count)
        )
    }
}

// MARK: - Statistics Model
struct ProgressStatistics {
    let totalSkills: Int
    let assessedSkills: Int
    let confidentSkills: Int
    let recentAssessments: Int
    let completionPercentage: Double
}
