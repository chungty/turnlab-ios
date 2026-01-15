import Foundation

/// Represents a message in the AI coach conversation.
struct CoachMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    var actions: [CoachAction]?

    enum MessageRole: String, Codable {
        case user
        case assistant
        case system
    }

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        actions: [CoachAction]? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.actions = actions
    }

    static func userMessage(_ content: String) -> CoachMessage {
        CoachMessage(role: .user, content: content)
    }

    static func assistantMessage(_ content: String, actions: [CoachAction]? = nil) -> CoachMessage {
        CoachMessage(role: .assistant, content: content, actions: actions)
    }
}

/// An action the coach can suggest (e.g., navigate to a skill).
struct CoachAction: Identifiable, Codable, Equatable {
    let id: UUID
    let type: ActionType
    let label: String
    let payload: String // skill ID, rating, etc.

    enum ActionType: String, Codable {
        case navigateToSkill
        case setFocusSkill
        case recordAssessment
        case showPremium
        case enableDailyTips
        case startPractice
    }

    init(type: ActionType, label: String, payload: String) {
        self.id = UUID()
        self.type = type
        self.label = label
        self.payload = payload
    }

    /// The SF Symbol icon for this action type.
    var icon: String {
        switch type {
        case .navigateToSkill:
            return "arrow.right.circle.fill"
        case .setFocusSkill:
            return "star.fill"
        case .recordAssessment:
            return "checkmark.circle.fill"
        case .showPremium:
            return "crown.fill"
        case .enableDailyTips:
            return "bell.fill"
        case .startPractice:
            return "play.circle.fill"
        }
    }

    /// The accent color for this action type.
    var colorName: String {
        switch type {
        case .navigateToSkill:
            return "blue"
        case .setFocusSkill:
            return "orange"
        case .recordAssessment:
            return "green"
        case .showPremium:
            return "purple"
        case .enableDailyTips:
            return "yellow"
        case .startPractice:
            return "teal"
        }
    }
}

// MARK: - Conversation Persistence

/// Manages local storage of coach conversations.
class CoachConversationStorage {
    private let key = "coach_conversation_history"
    private let maxMessages = 20 // Keep last 20 messages

    /// Saves messages to local storage.
    func save(_ messages: [CoachMessage]) {
        let toSave = Array(messages.suffix(maxMessages))
        if let data = try? JSONEncoder().encode(toSave) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    /// Loads messages from local storage.
    func load() -> [CoachMessage] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let messages = try? JSONDecoder().decode([CoachMessage].self, from: data) else {
            return []
        }
        return messages
    }

    /// Clears all stored messages.
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    /// Checks if this is the first time using the coach.
    var isFirstTime: Bool {
        !UserDefaults.standard.bool(forKey: "coach_has_been_used")
    }

    /// Marks the coach as having been used.
    func markAsUsed() {
        UserDefaults.standard.set(true, forKey: "coach_has_been_used")
    }

    /// Gets the last coach tip for widget display.
    func getLastCoachTip() -> String? {
        let messages = load()
        // Find the last assistant message that looks like a tip
        return messages
            .filter { $0.role == .assistant }
            .last
            .map { message in
                // Truncate for widget if needed
                let content = message.content
                if content.count > 100 {
                    return String(content.prefix(97)) + "..."
                }
                return content
            }
    }
}
