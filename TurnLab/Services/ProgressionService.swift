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

    /// Get suggested skills with reasons explaining why they're recommended
    func suggestedSkillsWithReasons(
        currentLevel: SkillLevel,
        limit: Int = 3
    ) async -> [SuggestedSkillWithReason] {
        let skills = await skillRepository.getSkills(for: currentLevel)
        let ratingSummary = await assessmentRepository.getSkillRatingSummary()

        // Build suggestions with reasons
        var suggestions: [SuggestedSkillWithReason] = []

        for skill in skills {
            let rating = ratingSummary[skill.id] ?? .notAssessed
            let reason: RecommendationReason

            switch rating {
            case .notAssessed:
                // Check if this is a foundation skill (no prerequisites)
                if skill.prerequisites.isEmpty && skill.level == .beginner {
                    reason = .buildingFoundation
                } else {
                    reason = .notYetAssessed
                }
            case .needsWork:
                reason = .needsMorePractice
            case .developing:
                reason = .nextInProgression
            case .confident, .mastered:
                continue // Skip already confident/mastered skills
            }

            suggestions.append(SuggestedSkillWithReason(skill: skill, reason: reason))
        }

        // Sort: foundation first, then unassessed, then needs work, then developing
        suggestions.sort { s1, s2 in
            func priority(_ reason: RecommendationReason) -> Int {
                switch reason {
                case .buildingFoundation: return 0
                case .notYetAssessed: return 1
                case .needsMorePractice: return 2
                case .nextInProgression: return 3
                case .domainBalance: return 4
                }
            }
            return priority(s1.reason) < priority(s2.reason)
        }

        return Array(suggestions.prefix(limit))
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

// MARK: - Suggested Skill with Reason
struct SuggestedSkillWithReason: Identifiable {
    let skill: Skill
    let reason: RecommendationReason

    var id: String { skill.id }
}

enum RecommendationReason {
    case notYetAssessed
    case needsMorePractice
    case buildingFoundation
    case nextInProgression
    case domainBalance(SkillDomain)

    var displayText: String {
        switch self {
        case .notYetAssessed:
            return "Not yet assessed"
        case .needsMorePractice:
            return "Needs more practice"
        case .buildingFoundation:
            return "Foundation skill"
        case .nextInProgression:
            return "Next in your journey"
        case .domainBalance(let domain):
            return "Strengthen your \(domain.displayName.lowercased())"
        }
    }

    var icon: String {
        switch self {
        case .notYetAssessed:
            return "circle.dashed"
        case .needsMorePractice:
            return "arrow.clockwise"
        case .buildingFoundation:
            return "building.columns"
        case .nextInProgression:
            return "arrow.right.circle"
        case .domainBalance:
            return "scale.3d"
        }
    }
}
