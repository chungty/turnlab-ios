import Foundation

/// Service for communicating with OpenAI's Chat API.
actor OpenAIService {
    private let apiKey: String
    private let baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private let model = "gpt-4o-mini" // Cost-effective for chat

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    struct ChatRequest: Encodable {
        let model: String
        let messages: [Message]
        let temperature: Double
        let max_tokens: Int

        struct Message: Encodable {
            let role: String
            let content: String
        }
    }

    struct ChatResponse: Decodable {
        let choices: [Choice]
        let usage: Usage?

        struct Choice: Decodable {
            let message: Message
            let finish_reason: String?
        }

        struct Message: Decodable {
            let role: String
            let content: String
        }

        struct Usage: Decodable {
            let prompt_tokens: Int
            let completion_tokens: Int
            let total_tokens: Int
        }
    }

    struct APIError: Decodable {
        let error: ErrorDetail

        struct ErrorDetail: Decodable {
            let message: String
            let type: String
            let code: String?
        }
    }

    enum OpenAIError: LocalizedError {
        case invalidResponse
        case apiError(String)
        case networkError(Error)
        case rateLimited
        case unauthorized

        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid response from AI service"
            case .apiError(let message):
                return "AI service error: \(message)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .rateLimited:
                return "Too many requests. Please wait a moment."
            case .unauthorized:
                return "AI service not available"
            }
        }
    }

    /// Sends a chat completion request to OpenAI.
    func sendChatCompletion(
        systemPrompt: String,
        messages: [(role: String, content: String)],
        temperature: Double = 0.7,
        maxTokens: Int = 1024
    ) async throws -> String {
        var allMessages = [ChatRequest.Message(role: "system", content: systemPrompt)]

        for msg in messages {
            allMessages.append(ChatRequest.Message(role: msg.role, content: msg.content))
        }

        let request = ChatRequest(
            model: model,
            messages: allMessages,
            temperature: temperature,
            max_tokens: maxTokens
        )

        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        urlRequest.timeoutInterval = 30

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenAIError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200:
                let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                guard let content = chatResponse.choices.first?.message.content else {
                    throw OpenAIError.invalidResponse
                }
                return content

            case 401:
                throw OpenAIError.unauthorized

            case 429:
                throw OpenAIError.rateLimited

            default:
                if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw OpenAIError.apiError(apiError.error.message)
                }
                throw OpenAIError.apiError("HTTP \(httpResponse.statusCode)")
            }

        } catch let error as OpenAIError {
            throw error
        } catch {
            throw OpenAIError.networkError(error)
        }
    }
}
