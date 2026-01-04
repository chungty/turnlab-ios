import Foundation

/// Loads content from bundled JSON files.
final class ContentLoader {
    enum ContentLoadError: Error {
        case fileNotFound(String)
        case decodingError(Error)
    }

    /// Load skills from bundled JSON
    static func loadSkills() throws -> [Skill] {
        try load(from: "skills", as: [Skill].self)
    }

    /// Load quiz questions from bundled JSON
    static func loadQuizQuestions() throws -> [QuizQuestion] {
        try load(from: "quiz", as: [QuizQuestion].self)
    }

    /// Generic JSON loader
    private static func load<T: Decodable>(from filename: String, as type: T.Type) throws -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw ContentLoadError.fileNotFound(filename)
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw ContentLoadError.decodingError(error)
        }
    }
}
