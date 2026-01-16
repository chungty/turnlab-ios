import SwiftUI
import Combine

/// ViewModel for the AI coach chat interface.
@MainActor
final class CoachViewModel: ObservableObject {
    // MARK: - Published State
    @Published var messages: [CoachMessage] = []
    @Published var inputText: String = ""
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published var suggestedPrompts: [String] = []

    // Action confirmation
    @Published var showingActionConfirmation = false
    @Published var pendingAction: CoachAction?
    var pendingActionDescription: String {
        guard let action = pendingAction else { return "" }
        switch action.type {
        case .navigateToSkill:
            return "Go to \(action.label)?"
        case .setFocusSkill:
            return "Set this as your focus skill?"
        case .recordAssessment:
            return "Record this assessment?"
        case .showPremium:
            return "View premium upgrade options?"
        case .enableDailyTips:
            return "Enable daily coaching tips?"
        case .startPractice:
            return "Start practice session?"
        }
    }

    // MARK: - Dependencies
    private let coachService: CoachService
    private let skillRepository: SkillRepositoryProtocol
    private let assessmentRepository: AssessmentRepositoryProtocol
    private let storage = CoachConversationStorage()
    private var currentSkillContext: Skill?
    private var cancellables = Set<AnyCancellable>()

    // Callback for handling navigation actions
    var onNavigateToSkill: ((String) -> Void)?
    var onSetFocusSkill: ((String) -> Void)?
    var onShowPremium: (() -> Void)?

    // MARK: - Computed Properties

    var coachName: String {
        coachService.selectedCoach.rawValue
    }

    var isPremiumUser: Bool {
        coachService.canSendMessage || coachService.messagesUsedToday < 5
    }

    var remainingMessages: Int {
        coachService.remainingFreeMessages
    }

    // MARK: - Initialization
    init(
        coachService: CoachService,
        skillRepository: SkillRepositoryProtocol,
        assessmentRepository: AssessmentRepositoryProtocol
    ) {
        self.coachService = coachService
        self.skillRepository = skillRepository
        self.assessmentRepository = assessmentRepository

        // Observe coach service state
        coachService.$isProcessing
            .receive(on: DispatchQueue.main)
            .assign(to: &$isProcessing)

        coachService.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$errorMessage)

        // Load saved conversation or initialize new one
        loadOrInitializeConversation()
    }

    // MARK: - Public Methods

    /// Sets context for which skill the user is viewing.
    func setSkillContext(_ skill: Skill?) {
        currentSkillContext = skill
        updateSuggestedPrompts()

        // If setting a new skill context, optionally add a contextual message
        if let skill = skill, messages.count <= 1 {
            let contextMessage = CoachMessage.assistantMessage(
                "I see you're checking out **\(skill.name)**! 🎿 \(skill.summary)\n\nWant me to explain it differently, or help you nail it?"
            )
            messages.append(contextMessage)
            saveConversation()
        }
    }

    /// Sends the current input as a message.
    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isProcessing else { return }

        // Add user message
        let userMessage = CoachMessage.userMessage(text)
        messages.append(userMessage)
        inputText = ""
        saveConversation()

        // Mark as used on first message
        if storage.isFirstTime {
            storage.markAsUsed()
        }

        // Get AI response (pass history without the message we just added - it's sent via `text` param)
        let response = await coachService.sendMessage(
            text,
            conversationHistory: Array(messages.dropLast()),
            currentSkillContext: currentSkillContext
        )

        messages.append(response)
        saveConversation()
        updateSuggestedPrompts()

        // Update widget with latest coach tip (extract first sentence or truncate)
        updateWidgetCoachTip(from: response.content)
    }

    /// Sends a suggested prompt as a message.
    func sendSuggestedPrompt(_ prompt: String) async {
        inputText = prompt
        await sendMessage()
    }

    /// Clears the conversation and starts fresh.
    func clearConversation() {
        messages = []
        storage.clear()
        initializeNewConversation()
    }

    /// Switches between Johnny and Paige.
    func switchCoach() {
        coachService.selectedCoach = coachService.selectedCoach == .johnny ? .paige : .johnny
        UserDefaults.standard.set(coachService.selectedCoach.rawValue, forKey: "selected_coach")

        // Add a message announcing the switch
        let greeting = coachService.selectedCoach.greeting
        messages.append(.assistantMessage(greeting))
        saveConversation()
    }

    /// Handles tapping an action button in a coach message.
    func handleAction(_ action: CoachAction) {
        // For premium, navigate directly
        if action.type == .showPremium {
            onShowPremium?()
            return
        }

        // For other actions, show confirmation
        pendingAction = action
        showingActionConfirmation = true
    }

    /// Confirms the pending action.
    func confirmPendingAction() {
        guard let action = pendingAction else { return }

        switch action.type {
        case .navigateToSkill:
            onNavigateToSkill?(action.payload)

        case .setFocusSkill:
            onSetFocusSkill?(action.payload)
            // Add confirmation message
            messages.append(.assistantMessage("Done! I've set that as your focus skill. Let's crush it! 🔥"))
            saveConversation()

        case .recordAssessment:
            // Parse payload: "skill_id:rating"
            let parts = action.payload.split(separator: ":")
            if parts.count >= 2 {
                let skillId = String(parts[0])
                let ratingInt = Int(parts[1]) ?? 1
                let rating = Rating(rawValue: ratingInt) ?? .developing

                // Save assessment to database (default to groomedBlue terrain context)
                Task {
                    _ = await assessmentRepository.saveAssessment(
                        skillId: skillId,
                        context: .groomedBlue,
                        rating: rating,
                        notes: "Recorded via AI coach"
                    )
                }

                messages.append(.assistantMessage("Got it! I've recorded your \(rating.displayName.lowercased()) assessment. Keep shredding! 🏔️"))
                saveConversation()
            }

        case .enableDailyTips:
            // TODO: Enable push notifications
            UserDefaults.standard.set(true, forKey: "coach_daily_tips_enabled")
            messages.append(.assistantMessage("Awesome! I'll send you a tip every day to keep you progressing. 📱"))
            saveConversation()

        case .startPractice:
            // TODO: Navigate to practice mode
            messages.append(.assistantMessage("Let's do this! Head to the skill and start drilling. 💪"))
            saveConversation()

        case .showPremium:
            onShowPremium?()
        }

        pendingAction = nil
    }

    /// Cancels the pending action.
    func cancelPendingAction() {
        pendingAction = nil
    }

    // MARK: - Private Methods

    private func loadOrInitializeConversation() {
        let saved = storage.load()
        if !saved.isEmpty {
            messages = saved
            updateSuggestedPrompts()
        } else {
            initializeNewConversation()
        }

        // Load selected coach preference
        if let savedCoach = UserDefaults.standard.string(forKey: "selected_coach"),
           let coach = CoachService.CoachPersona(rawValue: savedCoach) {
            coachService.selectedCoach = coach
        }
    }

    private func initializeNewConversation() {
        let welcomeMessage = coachService.getWelcomeMessage(isFirstTime: storage.isFirstTime)
        messages = [
            CoachMessage.assistantMessage(welcomeMessage)
        ]
        saveConversation()
        updateSuggestedPrompts()
    }

    private func saveConversation() {
        storage.save(messages)
    }

    private func updateSuggestedPrompts() {
        suggestedPrompts = coachService.getSuggestedPrompts(currentSkill: currentSkillContext)
    }

    /// Extracts a concise tip from the coach response for the widget.
    private func updateWidgetCoachTip(from content: String) {
        // Clean up markdown and extract a meaningful tip
        var tip = content
            .replacingOccurrences(of: "**", with: "")  // Remove bold markers
            .replacingOccurrences(of: "*", with: "")   // Remove italic markers
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Try to get the first meaningful sentence (not a greeting)
        let sentences = tip.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 10 }

        // Skip greeting-like first sentences
        let greetings = ["yo", "hey", "hi", "hello", "what's up", "sup", "alright"]
        var selectedSentence: String?

        for sentence in sentences {
            let lower = sentence.lowercased()
            let isGreeting = greetings.contains { lower.hasPrefix($0) }
            if !isGreeting && sentence.count > 15 {
                selectedSentence = sentence
                break
            }
        }

        // Use selected sentence or fall back to first 100 chars
        if let sentence = selectedSentence {
            tip = sentence.count > 100 ? String(sentence.prefix(97)) + "..." : sentence
        } else {
            tip = tip.count > 100 ? String(tip.prefix(97)) + "..." : tip
        }

        // Only update if we have something meaningful
        if tip.count > 15 {
            WidgetDataBridge.shared.updateCoachTip(tip)
        }
    }
}
