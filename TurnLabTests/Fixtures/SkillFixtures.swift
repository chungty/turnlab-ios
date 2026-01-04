import Foundation
@testable import TurnLab

/// Test fixtures for skill-related tests.
enum SkillFixtures {
    // MARK: - Skills

    static var beginnerSkill: Skill {
        Skill(
            id: "test-beginner-skill",
            name: "Test Beginner Skill",
            level: .beginner,
            domain: .balance,
            description: "A test skill for beginners.",
            whyItMatters: "Testing matters.",
            milestones: ["Milestone 1", "Milestone 2", "Milestone 3"],
            content: basicContent
        )
    }

    static var noviceSkill: Skill {
        Skill(
            id: "test-novice-skill",
            name: "Test Novice Skill",
            level: .novice,
            domain: .edgeControl,
            description: "A test skill for novice skiers.",
            whyItMatters: "Progress matters.",
            milestones: ["Advanced Milestone 1", "Advanced Milestone 2"],
            content: basicContent
        )
    }

    static var intermediateSkill: Skill {
        Skill(
            id: "test-intermediate-skill",
            name: "Test Intermediate Skill",
            level: .intermediate,
            domain: .rotaryMovements,
            description: "A test skill for intermediate skiers.",
            whyItMatters: "Technique matters.",
            milestones: ["Parallel Milestone 1"],
            content: basicContent
        )
    }

    static var expertSkill: Skill {
        Skill(
            id: "test-expert-skill",
            name: "Test Expert Skill",
            level: .expert,
            domain: .pressureManagement,
            description: "A test skill for expert skiers.",
            whyItMatters: "Mastery matters.",
            milestones: ["Expert Milestone 1", "Expert Milestone 2"],
            content: contentWithVideos
        )
    }

    static var allTestSkills: [Skill] {
        [beginnerSkill, noviceSkill, intermediateSkill, expertSkill]
    }

    // MARK: - Content

    static var basicContent: SkillContent {
        SkillContent(
            videos: [],
            tips: [testTip],
            drills: [testDrill],
            checklists: [],
            warnings: []
        )
    }

    static var contentWithVideos: SkillContent {
        SkillContent(
            videos: [testVideo],
            tips: [testTip],
            drills: [testDrill],
            checklists: [testChecklist],
            warnings: ["Be careful on icy terrain"]
        )
    }

    // MARK: - Components

    static var testVideo: VideoReference {
        VideoReference(
            id: "test-video-1",
            title: "Test Video",
            youtubeId: "abc123",
            channelName: "Test Channel",
            durationSeconds: 300,
            description: "A test video description."
        )
    }

    static var testTip: Tip {
        Tip(
            id: "test-tip-1",
            content: "This is a test tip for your skiing.",
            category: .technique
        )
    }

    static var testDrill: Drill {
        Drill(
            id: "test-drill-1",
            name: "Test Drill",
            description: "A drill for testing purposes.",
            steps: ["Step 1", "Step 2", "Step 3"],
            durationMinutes: 10,
            terrain: .groomed
        )
    }

    static var testChecklist: Checklist {
        Checklist(
            id: "test-checklist-1",
            title: "Test Checklist",
            items: ["Item 1", "Item 2", "Item 3"]
        )
    }

    // MARK: - Quiz

    static var testQuizQuestion: QuizQuestion {
        QuizQuestion(
            id: "test-q1",
            text: "What is your ski level?",
            options: [
                QuizOption(
                    text: "Beginner",
                    levelScores: [.beginner: 3, .novice: 0, .intermediate: 0, .expert: 0]
                ),
                QuizOption(
                    text: "Intermediate",
                    levelScores: [.beginner: 0, .novice: 0, .intermediate: 3, .expert: 0]
                ),
                QuizOption(
                    text: "Expert",
                    levelScores: [.beginner: 0, .novice: 0, .intermediate: 0, .expert: 3]
                )
            ]
        )
    }

    static var testQuizQuestions: [QuizQuestion] {
        [testQuizQuestion]
    }
}
