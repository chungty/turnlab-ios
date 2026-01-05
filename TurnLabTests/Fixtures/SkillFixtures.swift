import Foundation
@testable import TurnLab

/// Test fixtures for skill-related tests.
enum SkillFixtures {
    // MARK: - Outcome Milestones

    static var testOutcomeMilestones: Skill.OutcomeMilestones {
        Skill.OutcomeMilestones(
            needsWork: "Struggling with the basics",
            developing: "Making progress but needs practice",
            confident: "Performing well in most conditions",
            mastered: "Expert level execution"
        )
    }

    // MARK: - Skills

    static var beginnerSkill: Skill {
        Skill(
            id: "test-beginner-skill",
            name: "Test Beginner Skill",
            level: .beginner,
            domains: [.balance],
            prerequisites: [],
            summary: "A test skill for beginners.",
            outcomeMilestones: testOutcomeMilestones,
            assessmentContexts: [.groomedGreen],
            content: basicContent
        )
    }

    static var beginnerSkill2: Skill {
        Skill(
            id: "test-beginner-skill-2",
            name: "Test Beginner Skill 2",
            level: .beginner,
            domains: [.balance, .edgeControl],
            prerequisites: [],
            summary: "Another test skill for beginners.",
            outcomeMilestones: testOutcomeMilestones,
            assessmentContexts: [.groomedGreen],
            content: basicContent
        )
    }

    static var noviceSkill: Skill {
        Skill(
            id: "test-novice-skill",
            name: "Test Novice Skill",
            level: .novice,
            domains: [.edgeControl],
            prerequisites: ["test-beginner-skill"],
            summary: "A test skill for novice skiers.",
            outcomeMilestones: testOutcomeMilestones,
            assessmentContexts: [.groomedGreen, .bumps],
            content: basicContent
        )
    }

    static var intermediateSkill: Skill {
        Skill(
            id: "test-intermediate-skill",
            name: "Test Intermediate Skill",
            level: .intermediate,
            domains: [.rotaryMovements],
            prerequisites: ["test-novice-skill"],
            summary: "A test skill for intermediate skiers.",
            outcomeMilestones: testOutcomeMilestones,
            assessmentContexts: [.groomedGreen, .bumps, .steeps],
            content: basicContent
        )
    }

    static var expertSkill: Skill {
        Skill(
            id: "test-expert-skill",
            name: "Test Expert Skill",
            level: .expert,
            domains: [.pressureManagement, .edgeControl],
            prerequisites: ["test-intermediate-skill"],
            summary: "A test skill for expert skiers.",
            outcomeMilestones: testOutcomeMilestones,
            assessmentContexts: [.groomedGreen, .bumps, .steeps, .powder],
            content: contentWithVideos
        )
    }

    static var allTestSkills: [Skill] {
        [beginnerSkill, beginnerSkill2, noviceSkill, intermediateSkill, expertSkill]
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
            warnings: [testWarning]
        )
    }

    // MARK: - Components

    static var testVideo: VideoReference {
        VideoReference(
            id: "test-video-1",
            title: "Test Video",
            youtubeId: "abc123",
            channelName: "Test Channel",
            duration: 300,
            isPrimary: true
        )
    }

    static var testTip: Tip {
        Tip(
            id: "test-tip-1",
            title: "Test Tip",
            content: "This is a test tip for your skiing.",
            category: .focus,
            isQuickReference: true
        )
    }

    static var testDrill: Drill {
        Drill(
            id: "test-drill-1",
            title: "Test Drill",
            overview: "A drill for testing purposes.",
            steps: [
                Drill.DrillStep(order: 1, instruction: "Step 1", focusPoint: "Focus on balance"),
                Drill.DrillStep(order: 2, instruction: "Step 2", focusPoint: nil),
                Drill.DrillStep(order: 3, instruction: "Step 3", focusPoint: "Maintain speed")
            ],
            difficulty: .easy,
            recommendedTerrain: [.groomedGreen],
            estimatedReps: "3-5 times"
        )
    }

    static var testChecklist: Checklist {
        Checklist(
            id: "test-checklist-1",
            title: "Test Checklist",
            items: [
                Checklist.ChecklistItem(order: 1, text: "Item 1", isCritical: false),
                Checklist.ChecklistItem(order: 2, text: "Item 2", isCritical: false),
                Checklist.ChecklistItem(order: 3, text: "Item 3", isCritical: true)
            ],
            purpose: .preRun
        )
    }

    static var testWarning: SafetyWarning {
        SafetyWarning(
            id: "test-warning-1",
            title: "Be careful",
            content: "Be careful on icy terrain",
            severity: .caution,
            applicableContexts: [.steeps]
        )
    }

    // MARK: - Quiz

    static var testQuizQuestion: QuizQuestion {
        QuizQuestion(
            id: "test-q1",
            scenario: "What is your current ski level?",
            options: [
                QuizQuestion.QuizOption(
                    id: "test-q1-a",
                    text: "Beginner - just learning",
                    levelPoints: ["0": 3, "1": 0, "2": 0, "3": 0]
                ),
                QuizQuestion.QuizOption(
                    id: "test-q1-b",
                    text: "Intermediate - comfortable on groomed",
                    levelPoints: ["0": 0, "1": 1, "2": 3, "3": 0]
                ),
                QuizQuestion.QuizOption(
                    id: "test-q1-c",
                    text: "Expert - all terrain",
                    levelPoints: ["0": 0, "1": 0, "2": 0, "3": 3]
                )
            ],
            order: 1
        )
    }

    static var testQuizQuestions: [QuizQuestion] {
        [testQuizQuestion]
    }
}
