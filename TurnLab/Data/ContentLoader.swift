import Foundation

/// Loads content from bundled JSON files.
final class ContentLoader {
    enum ContentLoadError: Error {
        case fileNotFound(String)
        case decodingError(Error)
    }

    // MARK: - Wrapper Types for JSON
    private struct SkillsWrapper: Decodable {
        let skills: [Skill]
    }

    /// Load skills from bundled JSON
    static func loadSkills() throws -> [Skill] {
        let wrapper: SkillsWrapper = try load(from: "skills")
        return wrapper.skills
    }

    /// Load quiz questions from bundled JSON
    static func loadQuizQuestions() throws -> [QuizQuestion] {
        try load(from: "quiz")
    }

    /// Generic JSON loader
    private static func load<T: Decodable>(from filename: String) throws -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw ContentLoadError.fileNotFound(filename)
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            // JSON uses camelCase keys - no conversion needed
            return try decoder.decode(T.self, from: data)
        } catch {
            print("ContentLoader: Failed to decode \(filename).json - \(error)")
            throw ContentLoadError.decodingError(error)
        }
    }
}
