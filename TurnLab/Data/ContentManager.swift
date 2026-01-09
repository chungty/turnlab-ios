import Foundation

/// In-memory cache for app content.
/// Loads from bundled JSON on startup.
@MainActor
final class ContentManager: ObservableObject {
    @Published private(set) var skills: [Skill] = []
    @Published private(set) var quizQuestions: [QuizQuestion] = []
    @Published private(set) var isLoaded = false
    @Published private(set) var loadError: Error?

    // MARK: - Loading
    func loadContent() async {
        do {
            print("ContentManager: Starting to load content...")
            skills = try ContentLoader.loadSkills()
            print("ContentManager: Loaded \(skills.count) skills")
            quizQuestions = try ContentLoader.loadQuizQuestions()
            print("ContentManager: Loaded \(quizQuestions.count) quiz questions")
            isLoaded = true
            print("ContentManager: Content loaded successfully!")
        } catch {
            loadError = error
            print("ContentManager: Failed to load content: \(error)")
            // Load fallback content for development/preview
            loadFallbackContent()
        }
    }

    // MARK: - Skill Access
    func skill(byId id: String) -> Skill? {
        skills.first { $0.id == id }
    }

    func skills(forLevel level: SkillLevel) -> [Skill] {
        skills.filter { $0.level == level }
    }

    func skills(forDomain domain: SkillDomain) -> [Skill] {
        skills.filter { $0.domains.contains(domain) }
    }

    // MARK: - Quiz Access
    var sortedQuizQuestions: [QuizQuestion] {
        quizQuestions.sorted { $0.order < $1.order }
    }

    // MARK: - Fallback Content
    private func loadFallbackContent() {
        // Minimal fallback content for when JSON isn't available
        skills = Self.fallbackSkills
        quizQuestions = Self.fallbackQuizQuestions
        isLoaded = true
    }

    // MARK: - Fallback Data
    private static var fallbackSkills: [Skill] {
        [
            Skill(
                id: "basic-stance",
                name: "Basic Stance & Balance",
                level: .beginner,
                domains: [.balance],
                prerequisites: [],
                summary: "Learn the fundamental athletic stance for skiing.",
                outcomeMilestones: Skill.OutcomeMilestones(
                    needsWork: "Struggling to maintain balance on flat terrain",
                    developing: "Can hold stance briefly but loses balance easily",
                    confident: "Maintains athletic stance comfortably on gentle terrain",
                    mastered: "Stance is automatic and adaptable to changing terrain"
                ),
                assessmentContexts: [.groomedGreen],
                content: SkillContent(
                    videos: [
                        VideoReference(
                            id: "v1",
                            title: "Ski Stance Fundamentals",
                            youtubeId: "dQw4w9WgXcQ",
                            channelName: "Sample Channel",
                            duration: 300,
                            isPrimary: true
                        )
                    ],
                    tips: [
                        Tip(
                            id: "t1",
                            title: "Athletic Ready Position",
                            content: "Bend your ankles, knees, and hips slightly. Keep your weight centered over your feet.",
                            category: .bodyPosition,
                            isQuickReference: true
                        )
                    ],
                    drills: [],
                    checklists: [],
                    warnings: []
                )
            )
        ]
    }

    private static var fallbackQuizQuestions: [QuizQuestion] {
        [
            QuizQuestion(
                id: "q1",
                scenario: "On a gentle green run, you typically:",
                options: [
                    QuizQuestion.QuizOption(
                        id: "q1a",
                        text: "Feel nervous and use a snowplow most of the time",
                        levelPoints: ["0": 3, "1": 1, "2": 0, "3": 0]
                    ),
                    QuizQuestion.QuizOption(
                        id: "q1b",
                        text: "Ski comfortably with wedge turns",
                        levelPoints: ["0": 1, "1": 3, "2": 1, "3": 0]
                    ),
                    QuizQuestion.QuizOption(
                        id: "q1c",
                        text: "Ski with parallel turns easily",
                        levelPoints: ["0": 0, "1": 1, "2": 3, "3": 1]
                    ),
                    QuizQuestion.QuizOption(
                        id: "q1d",
                        text: "Find it too easy and look for steeper terrain",
                        levelPoints: ["0": 0, "1": 0, "2": 1, "3": 3]
                    )
                ],
                order: 1
            )
        ]
    }
}
