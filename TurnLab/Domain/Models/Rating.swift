import Foundation
import SwiftUI

/// Self-assessment rating for skill proficiency.
/// Outcome-based with clear benchmark descriptions.
enum Rating: Int, Codable, CaseIterable, Comparable {
    case notAssessed = 0
    case needsWork = 1
    case developing = 2
    case confident = 3
    case mastered = 4

    var displayName: String {
        switch self {
        case .notAssessed: return "Not Assessed"
        case .needsWork: return "Needs Work"
        case .developing: return "Developing"
        case .confident: return "Confident"
        case .mastered: return "Mastered"
        }
    }

    var shortName: String {
        switch self {
        case .notAssessed: return "—"
        case .needsWork: return "Needs Work"
        case .developing: return "Developing"
        case .confident: return "Confident"
        case .mastered: return "Mastered"
        }
    }

    var color: Color {
        switch self {
        case .notAssessed: return .gray
        case .needsWork: return .red
        case .developing: return .orange
        case .confident: return .green
        case .mastered: return .blue
        }
    }

    var iconName: String {
        switch self {
        case .notAssessed: return "circle.dashed"
        case .needsWork: return "exclamationmark.circle"
        case .developing: return "arrow.up.circle"
        case .confident: return "checkmark.circle"
        case .mastered: return "star.circle.fill"
        }
    }

    /// Whether this rating counts toward level progression
    var countsTowardProgression: Bool {
        self >= .confident
    }

    /// Progress value (0.0 - 1.0) for visual indicators
    var progressValue: Double {
        switch self {
        case .notAssessed: return 0.0
        case .needsWork: return 0.25
        case .developing: return 0.5
        case .confident: return 0.75
        case .mastered: return 1.0
        }
    }

    static func < (lhs: Rating, rhs: Rating) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
