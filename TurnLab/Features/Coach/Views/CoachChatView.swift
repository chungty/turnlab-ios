import SwiftUI
import Speech

/// The main chat interface for the AI ski coach.
struct CoachChatView: View {
    @ObservedObject var viewModel: CoachViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Rate limit indicator for free users
                if !viewModel.isPremiumUser && viewModel.remainingMessages < 5 {
                    RateLimitBanner(remaining: viewModel.remainingMessages)
                }

                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                CoachMessageBubble(
                                    message: message,
                                    coachName: viewModel.coachName
                                ) { action in
                                    viewModel.handleAction(action)
                                }
                            }

                            // Typing indicator
                            if viewModel.isProcessing {
                                TypingIndicator(coachName: viewModel.coachName)
                                    .id("typing")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: viewModel.isProcessing) { _, isProcessing in
                        if isProcessing {
                            scrollToBottom(proxy: proxy)
                        }
                    }
                }

                // Suggested Prompts
                if !viewModel.suggestedPrompts.isEmpty && viewModel.messages.count <= 2 {
                    SuggestedPromptsView(
                        prompts: viewModel.suggestedPrompts,
                        onSelect: { prompt in
                            Task {
                                await viewModel.sendSuggestedPrompt(prompt)
                            }
                        }
                    )
                }

                Divider()

                // Input Area with Voice Support
                ChatInputView(
                    text: $viewModel.inputText,
                    isProcessing: viewModel.isProcessing,
                    isFocused: $isInputFocused,
                    onSend: {
                        Task {
                            await viewModel.sendMessage()
                        }
                    },
                    onVoiceInput: { transcription in
                        viewModel.inputText = transcription
                    }
                )
            }
            .navigationTitle(viewModel.coachName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.switchCoach()
                        } label: {
                            Label("Switch Coach", systemImage: "person.2")
                        }

                        Divider()

                        Button(role: .destructive) {
                            viewModel.clearConversation()
                        } label: {
                            Label("Clear Chat", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Action", isPresented: $viewModel.showingActionConfirmation) {
                Button("Confirm") {
                    viewModel.confirmPendingAction()
                }
                Button("Cancel", role: .cancel) {
                    viewModel.cancelPendingAction()
                }
            } message: {
                Text(viewModel.pendingActionDescription)
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            if viewModel.isProcessing {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let lastMessage = viewModel.messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

// MARK: - Rate Limit Banner

struct RateLimitBanner: View {
    let remaining: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.caption)
            Text(remaining == 0
                 ? "Daily limit reached"
                 : "\(remaining) free message\(remaining == 1 ? "" : "s") left today")
                .font(.caption)
            Spacer()
            if remaining == 0 {
                Text("Upgrade for unlimited")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemYellow).opacity(0.2))
    }
}

// MARK: - Message Bubble

struct CoachMessageBubble: View {
    let message: CoachMessage
    let coachName: String
    var onAction: ((CoachAction) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.role == .assistant {
                // Coach avatar
                CoachAvatar(name: coachName)
            } else {
                Spacer()
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 8) {
                // Message content
                Text(LocalizedStringKey(message.content))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.role == .user
                            ? Color.blue
                            : Color(.systemGray6)
                    )
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Actions (if any)
                if let actions = message.actions, !actions.isEmpty {
                    VStack(spacing: 6) {
                        ForEach(actions) { action in
                            ActionButton(action: action) {
                                onAction?(action)
                            }
                        }
                    }
                }
            }

            if message.role == .user {
                // User doesn't need avatar
            } else {
                Spacer()
            }
        }
        .id(message.id)
    }
}

// MARK: - Coach Avatar

struct CoachAvatar: View {
    let name: String

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color.blue, Color.cyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 36, height: 36)
            .overlay {
                Text(name.prefix(1))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let action: CoachAction
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: action.icon)
                    .font(.caption)
                Text(action.label)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(actionColor.opacity(0.15))
            .foregroundColor(actionColor)
            .clipShape(Capsule())
        }
    }

    private var actionColor: Color {
        switch action.type {
        case .navigateToSkill: return .blue
        case .setFocusSkill: return .orange
        case .recordAssessment: return .green
        case .showPremium: return .purple
        case .enableDailyTips: return .yellow
        case .startPractice: return .teal
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    let coachName: String
    @State private var animating = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            CoachAvatar(name: coachName)

            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animating ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(index) * 0.15),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()
        }
        .onAppear {
            animating = true
        }
    }
}

// MARK: - Suggested Prompts

struct SuggestedPromptsView: View {
    let prompts: [String]
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(prompts, id: \.self) { prompt in
                    Button {
                        onSelect(prompt)
                    } label: {
                        Text(prompt)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Chat Input with Voice

struct ChatInputView: View {
    @Binding var text: String
    let isProcessing: Bool
    var isFocused: FocusState<Bool>.Binding
    let onSend: () -> Void
    var onVoiceInput: ((String) -> Void)?

    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false

    var body: some View {
        HStack(spacing: 12) {
            // Voice input button
            Button {
                toggleRecording()
            } label: {
                Image(systemName: isRecording ? "mic.fill" : "mic")
                    .font(.system(size: 20))
                    .foregroundColor(isRecording ? .red : .gray)
                    .frame(width: 32, height: 32)
            }
            .disabled(isProcessing)

            // Text input
            TextField("Ask your coach...", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .focused(isFocused)
                .lineLimit(1...4)
                .submitLabel(.send)
                .onSubmit {
                    if !text.isEmpty && !isProcessing {
                        onSend()
                    }
                }

            // Send button
            Button {
                onSend()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(canSend ? .blue : .gray)
            }
            .disabled(!canSend)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .onChange(of: speechRecognizer.transcription) { _, newValue in
            if !newValue.isEmpty {
                text = newValue
                onVoiceInput?(newValue)
            }
        }
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isProcessing
    }

    private func toggleRecording() {
        if isRecording {
            speechRecognizer.stopRecording()
        } else {
            speechRecognizer.startRecording()
        }
        isRecording.toggle()
    }
}

// MARK: - Speech Recognizer

class SpeechRecognizer: ObservableObject {
    @Published var transcription = ""
    @Published var isAvailable = false

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    init() {
        checkPermission()
    }

    func checkPermission() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.isAvailable = status == .authorized
            }
        }
    }

    func startRecording() {
        // Cancel previous task if any
        recognitionTask?.cancel()
        recognitionTask = nil

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error)")
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { return }

        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self?.transcription = result.bestTranscription.formattedString
                }
            }

            if error != nil || (result?.isFinal ?? false) {
                self?.stopRecording()
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
    }
}

// MARK: - Preview

#Preview {
    CoachChatView(
        viewModel: CoachViewModel(
            coachService: CoachService(
                openAIService: OpenAIService(apiKey: "preview-key"),
                skillRepository: MockSkillRepository(),
                assessmentRepository: MockAssessmentRepository(),
                appState: AppState()
            ),
            skillRepository: MockSkillRepository(),
            assessmentRepository: MockAssessmentRepository()
        )
    )
}

// MARK: - Mock Repositories for Preview

@MainActor
private class MockSkillRepository: SkillRepositoryProtocol {
    func getAllSkills() async -> [Skill] { [] }
    func getSkill(id: String) async -> Skill? { nil }
    func getSkills(for level: SkillLevel) async -> [Skill] { [] }
    func getSkills(for domain: SkillDomain) async -> [Skill] { [] }
    func getPrerequisites(for skillId: String) async -> [Skill] { [] }
    func searchSkills(query: String) async -> [Skill] { [] }
    func getAccessibleSkills(isPremium: Bool) async -> [Skill] { [] }
}

private class MockAssessmentRepository: AssessmentRepositoryProtocol {
    func saveAssessment(skillId: String, context: TerrainContext, rating: Rating, notes: String?) async -> AssessmentEntity {
        fatalError("Not implemented for preview")
    }
    func getAssessments(for skillId: String) async -> [AssessmentEntity] { [] }
    func getLatestAssessment(for skillId: String, context: TerrainContext) async -> AssessmentEntity? { nil }
    func getBestRating(for skillId: String) async -> Rating { .notAssessed }
    func getAllAssessments() async -> [AssessmentEntity] { [] }
    func getAssessmentCounts() async -> [Rating: Int] { [:] }
    func getRecentAssessments(days: Int) async -> [AssessmentEntity] { [] }
    func deleteAssessment(_ assessment: AssessmentEntity) async {}
    func getSkillRatingSummary() async -> [String: Rating] { [:] }
}
