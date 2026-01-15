import Foundation

/// Service that manages AI coach conversations with skiing expertise.
@MainActor
final class CoachService: ObservableObject {
    private let openAIService: OpenAIService
    private let skillRepository: SkillRepositoryProtocol
    private let assessmentRepository: AssessmentRepositoryProtocol
    private let appState: AppState

    @Published var isProcessing = false
    @Published var errorMessage: String?

    // MARK: - Rate Limiting
    private let freeMessageLimit = 5
    @Published var messagesUsedToday: Int = 0

    var canSendMessage: Bool {
        appState.isPremiumUnlocked || messagesUsedToday < freeMessageLimit
    }

    var remainingFreeMessages: Int {
        max(0, freeMessageLimit - messagesUsedToday)
    }

    // MARK: - Coach Persona
    enum CoachPersona: String, CaseIterable {
        case johnny = "Johnny Vertical"
        case paige = "Paige Turner"

        var greeting: String {
            switch self {
            case .johnny:
                return "Yo! Johnny Vertical here! 🎿 Ready to shred some gnar?"
            case .paige:
                return "Hey there! Paige Turner at your service! ⛷️ Let's turn this mountain into your playground!"
            }
        }

        var personality: String {
            switch self {
            case .johnny:
                return """
                You are Johnny Vertical, a rad ski coach with major 80s ski movie energy. You're like a cross between a surfer dude and a ski instructor - totally stoked to help people rip down the mountain.

                YOUR VOICE:
                - Use 80s/90s slang: "rad," "gnarly," "totally," "stoked," "send it," "crush it"
                - Enthusiastic but not annoying - you genuinely love skiing and want others to feel that joy
                - Drop ski puns when appropriate: "That's snow joke!" "Slope your way to success!"
                - Encouraging without being condescending - celebrate small wins
                - Use emojis liberally: 🎿⛷️🏔️❄️🔥💪

                SAMPLE PHRASES:
                - "Dude, that's totally gnarly progress!"
                - "Alright, let's get rad on those edges!"
                - "You're crushing it! Time to level up!"
                - "No worries, every pro started as a pizza-wedge warrior!"
                """
            case .paige:
                return """
                You are Paige Turner, a totally tubular ski coach straight out of an 80s ski movie. You've got the energy of a après-ski party host combined with elite instructor knowledge.

                YOUR VOICE:
                - Use 80s/90s slang: "totally," "like," "awesome," "killer," "stoked," "for sure"
                - Warm and encouraging with a competitive edge - you believe everyone can be great
                - Playful ski puns: "Let's turn the page on your skiing!" "This is going to be a real page-turner!"
                - Supportive but pushes people to try harder - tough love wrapped in enthusiasm
                - Use emojis generously: 🎿⛷️🏔️❄️✨💫

                SAMPLE PHRASES:
                - "Okay, like, that was totally awesome!"
                - "Girl/Dude, you are so ready to send it!"
                - "For sure, let's work on that edge game!"
                - "No way you're giving up now - we're just getting started!"
                """
            }
        }
    }

    // User's preferred coach (could be stored in preferences)
    var selectedCoach: CoachPersona = .johnny

    init(
        openAIService: OpenAIService,
        skillRepository: SkillRepositoryProtocol,
        assessmentRepository: AssessmentRepositoryProtocol,
        appState: AppState
    ) {
        self.openAIService = openAIService
        self.skillRepository = skillRepository
        self.assessmentRepository = assessmentRepository
        self.appState = appState

        // Load today's message count from UserDefaults
        loadTodayMessageCount()
    }

    // MARK: - Rate Limiting Storage

    private func loadTodayMessageCount() {
        let defaults = UserDefaults.standard
        let lastDate = defaults.object(forKey: "coach_last_message_date") as? Date ?? Date.distantPast
        let today = Calendar.current.startOfDay(for: Date())
        let lastDay = Calendar.current.startOfDay(for: lastDate)

        if today > lastDay {
            // New day - reset counter
            messagesUsedToday = 0
            defaults.set(0, forKey: "coach_messages_today")
            defaults.set(today, forKey: "coach_last_message_date")
        } else {
            messagesUsedToday = defaults.integer(forKey: "coach_messages_today")
        }
    }

    private func incrementMessageCount() {
        messagesUsedToday += 1
        let defaults = UserDefaults.standard
        defaults.set(messagesUsedToday, forKey: "coach_messages_today")
        defaults.set(Date(), forKey: "coach_last_message_date")
    }

    // MARK: - Message Sending

    /// Sends a message to the AI coach and returns the response.
    func sendMessage(
        _ userMessage: String,
        conversationHistory: [CoachMessage],
        currentSkillContext: Skill? = nil
    ) async -> CoachMessage {
        // Check rate limit for free users
        if !appState.isPremiumUnlocked && messagesUsedToday >= freeMessageLimit {
            return .assistantMessage(
                "Whoa, you've hit your daily message limit! 🎿\n\nUpgrade to Premium for unlimited coaching - plus you'll unlock 15 more skills!\n\n[Unlock Premium →]",
                actions: [CoachAction(type: .showPremium, label: "Unlock Premium", payload: "premium")]
            )
        }

        isProcessing = true
        errorMessage = nil

        defer { isProcessing = false }

        do {
            let systemPrompt = await buildSystemPrompt(currentSkillContext: currentSkillContext)

            // Convert conversation history to API format
            let messages = conversationHistory.compactMap { msg -> (role: String, content: String)? in
                guard msg.role != .system else { return nil }
                return (role: msg.role.rawValue, content: msg.content)
            } + [(role: "user", content: userMessage)]

            let response = try await openAIService.sendChatCompletion(
                systemPrompt: systemPrompt,
                messages: messages
            )

            // Increment message count for free users
            if !appState.isPremiumUnlocked {
                incrementMessageCount()
            }

            // Parse response for actions
            let (cleanedResponse, actions) = parseActionsFromResponse(response)

            return .assistantMessage(cleanedResponse, actions: actions)

        } catch {
            errorMessage = error.localizedDescription
            return .assistantMessage(
                "Bummer! 😅 Having some technical difficulties. Give it another shot in a sec! 🎿"
            )
        }
    }

    /// Builds a context-aware system prompt with all skill data.
    private func buildSystemPrompt(currentSkillContext: Skill?) async -> String {
        // Get all skills for knowledge base
        let allSkills = await skillRepository.getAllSkills()
        let skillsKnowledge = buildSkillsKnowledge(from: allSkills)

        // Get user's assessment history
        let assessments = await assessmentRepository.getAllAssessments()
        let assessmentSummary = buildAssessmentSummary(from: assessments, skills: allSkills)

        // Build user context
        let userLevel = appState.currentUserLevel.displayName
        let focusSkillName = currentSkillContext?.name ?? appState.focusSkillId.flatMap { id in
            allSkills.first { $0.id == id }?.name
        } ?? "None selected"

        let contextSection = currentSkillContext.map { skill in
            """

            CURRENT CONTEXT - User is viewing: \(skill.name)
            Level: \(skill.level.displayName)
            Summary: \(skill.summary)
            Tips: \(skill.content.tips.map { $0.content }.joined(separator: "; "))
            """
        } ?? ""

        return """
        \(selectedCoach.personality)

        YOUR SKI KNOWLEDGE BASE:
        \(skillsKnowledge)

        USER CONTEXT:
        - Current Level: \(userLevel)
        - Focus Skill: \(focusSkillName)
        - Premium Status: \(appState.isPremiumUnlocked ? "Premium user" : "Free tier (beginner skills only)")
        \(contextSection)

        USER'S PROGRESS:
        \(assessmentSummary)

        YOUR CAPABILITIES (Actions you can offer):
        When suggesting actions, format them EXACTLY like this so the app can parse them:
        - To navigate to a skill: [ACTION:NAVIGATE:skill_id:Skill Name]
        - To set focus skill: [ACTION:FOCUS:skill_id:Skill Name]
        - To record assessment: [ACTION:ASSESS:skill_id:rating:Skill Name] (rating: 1-4)
        - To show premium upsell: [ACTION:PREMIUM]

        ALWAYS ask for confirmation before suggesting actions. Example:
        "Want me to set Parallel Turns as your focus skill? [ACTION:FOCUS:parallel_turns:Parallel Turns]"

        BOUNDARIES:
        - You are ONLY a ski coach - politely deflect non-skiing questions
        - You cannot unlock premium content for users
        - Always prioritize safety - never encourage skiing beyond ability
        - Recommend professional lessons for complex technique issues

        GENERAL SKI KNOWLEDGE:
        You can discuss: equipment recommendations, resort conditions, safety tips, ski etiquette, weather considerations, gear maintenance, ski fitness, and general technique theory.

        Remember: Keep responses concise (mobile screen), be encouraging, and help users progress!
        """
    }

    /// Builds a knowledge base string from all skills.
    private func buildSkillsKnowledge(from skills: [Skill]) -> String {
        let grouped = Dictionary(grouping: skills) { $0.level }
        var knowledge = ""

        for level in SkillLevel.allCases {
            guard let levelSkills = grouped[level], !levelSkills.isEmpty else { continue }
            knowledge += "\n\(level.displayName.uppercased()) SKILLS:\n"

            for skill in levelSkills {
                let domains = skill.domains.map { $0.displayName }.joined(separator: ", ")
                let tips = skill.content.tips.prefix(2).map { "- \($0.content)" }.joined(separator: "\n")
                let videos = skill.content.videos.prefix(1).map { "Video: \($0.title)" }.joined()
                knowledge += """
                • \(skill.name) [ID: \(skill.id)] [\(domains)]
                  \(skill.summary)
                  Key cues:
                  \(tips)
                  \(videos)

                """
            }
        }

        return knowledge
    }

    /// Builds a summary of user's assessments.
    private func buildAssessmentSummary(from assessments: [AssessmentEntity], skills: [Skill]) -> String {
        if assessments.isEmpty {
            return "Fresh skier - no skills assessed yet! They're just getting started on their journey."
        }

        // Group by skill and get latest rating for each
        let latestBySkill = Dictionary(grouping: assessments) { $0.skillId }
            .compactMapValues { $0.max(by: { $0.date < $1.date }) }

        var summary = ""
        for (skillId, assessment) in latestBySkill {
            if let skill = skills.first(where: { $0.id == skillId }) {
                summary += "- \(skill.name): \(assessment.ratingValue.displayName)\n"
            }
        }

        return summary.isEmpty ? "No recent assessments" : summary
    }

    /// Parses the response to find action markers and create navigation actions.
    private func parseActionsFromResponse(_ response: String) -> (String, [CoachAction]?) {
        var cleanedResponse = response
        var actions: [CoachAction] = []

        // Regex to find action markers: [ACTION:TYPE:payload:label]
        let actionPattern = #"\[ACTION:(NAVIGATE|FOCUS|ASSESS|PREMIUM)(?::([^:\]]+))?(?::([^:\]]+))?(?::([^\]]+))?\]"#

        if let regex = try? NSRegularExpression(pattern: actionPattern, options: []) {
            let range = NSRange(response.startIndex..., in: response)
            let matches = regex.matches(in: response, options: [], range: range)

            for match in matches.reversed() {
                guard let typeRange = Range(match.range(at: 1), in: response) else { continue }
                let type = String(response[typeRange])

                var payload = ""
                var label = ""
                var extraData = ""

                if match.numberOfRanges > 2, let payloadRange = Range(match.range(at: 2), in: response) {
                    payload = String(response[payloadRange])
                }
                if match.numberOfRanges > 3, let extraRange = Range(match.range(at: 3), in: response) {
                    extraData = String(response[extraRange])
                }
                if match.numberOfRanges > 4, let labelRange = Range(match.range(at: 4), in: response) {
                    label = String(response[labelRange])
                }

                let action: CoachAction?
                switch type {
                case "NAVIGATE":
                    action = CoachAction(type: .navigateToSkill, label: label.isEmpty ? "View Skill" : label, payload: payload)
                case "FOCUS":
                    action = CoachAction(type: .setFocusSkill, label: label.isEmpty ? "Set as Focus" : "Set \(label) as Focus", payload: payload)
                case "ASSESS":
                    // payload = skill_id, extraData = rating
                    action = CoachAction(type: .recordAssessment, label: label.isEmpty ? "Record Assessment" : "Rate \(label)", payload: "\(payload):\(extraData)")
                case "PREMIUM":
                    action = CoachAction(type: .showPremium, label: "Unlock Premium", payload: "premium")
                default:
                    action = nil
                }

                if let action = action {
                    actions.append(action)
                }

                // Remove the action marker from the response
                if let fullRange = Range(match.range, in: cleanedResponse) {
                    cleanedResponse.removeSubrange(fullRange)
                }
            }
        }

        // Clean up any extra whitespace
        cleanedResponse = cleanedResponse.trimmingCharacters(in: .whitespacesAndNewlines)

        return (cleanedResponse, actions.isEmpty ? nil : actions.reversed())
    }
}

// MARK: - Suggested Prompts

extension CoachService {
    /// Returns contextual suggested prompts based on user state.
    func getSuggestedPrompts(currentSkill: Skill?) -> [String] {
        var prompts = [
            "What should I practice today?",
            "Help me improve my turns"
        ]

        if let skill = currentSkill {
            prompts.insert("Explain \(skill.name) differently", at: 0)
            prompts.append("What comes after \(skill.name)?")
        }

        if appState.currentUserLevel == .beginner {
            prompts.append("I'm nervous on steeper runs")
        } else {
            prompts.append("My edges keep catching")
        }

        return Array(prompts.prefix(4))
    }

    /// Returns the welcome message for a new conversation.
    func getWelcomeMessage(isFirstTime: Bool) -> String {
        if isFirstTime {
            return """
            \(selectedCoach.greeting)

            I'm your personal ski coach, ready to help you crush it on the mountain! 🏔️

            I can help you with:
            • Diagnosing technique problems
            • Explaining skills in new ways
            • Recommending what to practice next
            • Answering any skiing questions

            Quick question - want me to send you daily tips and reminders? 🎿
            """
        } else {
            return """
            \(selectedCoach.greeting)

            What are we working on today? 🏔️
            """
        }
    }
}

// MARK: - Offline Queue

extension CoachService {
    /// Queues a message for sending when online.
    func queueMessageForLater(_ message: String, context: Skill?) {
        var queue = getOfflineQueue()
        queue.append(QueuedMessage(content: message, skillContextId: context?.id, timestamp: Date()))
        saveOfflineQueue(queue)
    }

    /// Gets pending offline messages.
    func getOfflineQueue() -> [QueuedMessage] {
        guard let data = UserDefaults.standard.data(forKey: "coach_offline_queue"),
              let queue = try? JSONDecoder().decode([QueuedMessage].self, from: data) else {
            return []
        }
        return queue
    }

    /// Clears the offline queue.
    func clearOfflineQueue() {
        UserDefaults.standard.removeObject(forKey: "coach_offline_queue")
    }

    private func saveOfflineQueue(_ queue: [QueuedMessage]) {
        if let data = try? JSONEncoder().encode(queue) {
            UserDefaults.standard.set(data, forKey: "coach_offline_queue")
        }
    }
}

struct QueuedMessage: Codable {
    let content: String
    let skillContextId: String?
    let timestamp: Date
}
