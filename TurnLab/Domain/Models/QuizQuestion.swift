import Foundation

/// Onboarding quiz question for initial skill assessment.
/// Scenario-based questions determine starting level.
struct QuizQuestion: Codable, Identifiable {
    let id: String
    let scenario: String
    let options: [QuizOption]
    let order: Int

    struct QuizOption: Codable, Identifiable, Hashable {
        let id: String
        let text: String
        let levelPoints: [String: Int] // Level raw value -> points

        func points(for level: SkillLevel) -> Int {
            levelPoints[String(level.rawValue)] ?? 0
        }
    }
}

/// Result of the onboarding quiz.
struct QuizResult: Codable {
    let recommendedLevel: SkillLevel
    let levelScores: [SkillLevel: Int]
    let completedAt: Date
    let answers: [String: String] // Question ID -> Selected Option ID

    /// Confidence percentage for the recommended level
    var confidence: Double {
        guard let maxScore = levelScores.values.max(), maxScore > 0 else { return 0 }
        let recommendedScore = levelScores[recommendedLevel] ?? 0
        return Double(recommendedScore) / Double(maxScore)
    }
}
