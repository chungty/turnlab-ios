import XCTest
@testable import TurnLab

final class SkillTests: XCTestCase {
    // MARK: - SkillLevel Tests

    func testSkillLevelOrdering() {
        XCTAssertTrue(SkillLevel.beginner < SkillLevel.novice)
        XCTAssertTrue(SkillLevel.novice < SkillLevel.intermediate)
        XCTAssertTrue(SkillLevel.intermediate < SkillLevel.expert)
    }

    func testSkillLevelDisplayName() {
        XCTAssertEqual(SkillLevel.beginner.displayName, "Beginner")
        XCTAssertEqual(SkillLevel.novice.displayName, "Novice")
        XCTAssertEqual(SkillLevel.intermediate.displayName, "Intermediate")
        XCTAssertEqual(SkillLevel.expert.displayName, "Expert")
    }

    func testSkillLevelAllCases() {
        XCTAssertEqual(SkillLevel.allCases.count, 4)
        XCTAssertEqual(SkillLevel.allCases, [.beginner, .novice, .intermediate, .expert])
    }

    func testSkillLevelRequiresPremium() {
        XCTAssertFalse(SkillLevel.beginner.requiresPremium)
        XCTAssertTrue(SkillLevel.novice.requiresPremium)
        XCTAssertTrue(SkillLevel.intermediate.requiresPremium)
        XCTAssertTrue(SkillLevel.expert.requiresPremium)
    }

    // MARK: - SkillDomain Tests

    func testSkillDomainAllCases() {
        XCTAssertEqual(SkillDomain.allCases.count, 5)
    }

    func testSkillDomainHasDisplayName() {
        for domain in SkillDomain.allCases {
            XCTAssertFalse(domain.displayName.isEmpty)
        }
    }

    func testSkillDomainHasIcon() {
        for domain in SkillDomain.allCases {
            XCTAssertFalse(domain.iconName.isEmpty)
        }
    }

    // MARK: - Rating Tests

    func testRatingOrdering() {
        XCTAssertTrue(Rating.needsWork < Rating.developing)
        XCTAssertTrue(Rating.developing < Rating.confident)
        XCTAssertTrue(Rating.confident < Rating.mastered)
    }

    func testRatingDisplayName() {
        XCTAssertEqual(Rating.needsWork.displayName, "Needs Work")
        XCTAssertEqual(Rating.mastered.displayName, "Mastered")
    }

    // MARK: - TerrainContext Tests

    func testTerrainContextAllCases() {
        // TerrainContext has 8 cases: groomedGreen, groomedBlue, groomedBlack, bumps, powder, steeps, ice, crud
        XCTAssertEqual(TerrainContext.allCases.count, 8)
    }

    func testTerrainContextDisplayName() {
        XCTAssertFalse(TerrainContext.groomedGreen.displayName.isEmpty)
        XCTAssertFalse(TerrainContext.bumps.displayName.isEmpty)
    }

    func testTerrainContextDifficultyWeight() {
        // Green should be easiest
        XCTAssertEqual(TerrainContext.groomedGreen.difficultyWeight, 1.0)
        // Steeps should be hardest
        XCTAssertEqual(TerrainContext.steeps.difficultyWeight, 3.0)
    }

    // MARK: - Skill Tests

    func testSkillCreation() {
        let skill = SkillFixtures.beginnerSkill

        XCTAssertEqual(skill.id, "test-beginner-skill")
        XCTAssertEqual(skill.level, .beginner)
        XCTAssertTrue(skill.domains.contains(.balance))
        XCTAssertFalse(skill.summary.isEmpty)
    }

    func testSkillContent() {
        let skill = SkillFixtures.expertSkill

        XCTAssertFalse(skill.content.videos.isEmpty)
        XCTAssertFalse(skill.content.tips.isEmpty)
        XCTAssertFalse(skill.content.drills.isEmpty)
        XCTAssertFalse(skill.content.checklists.isEmpty)
        XCTAssertFalse(skill.content.warnings.isEmpty)
    }

    func testSkillPrerequisites() {
        let noviceSkill = SkillFixtures.noviceSkill

        // Novice skill should have beginner skill as prerequisite
        XCTAssertTrue(noviceSkill.prerequisites.contains("test-beginner-skill"))
    }

    func testSkillOutcomeMilestones() {
        let skill = SkillFixtures.beginnerSkill

        XCTAssertFalse(skill.outcomeMilestones.needsWork.isEmpty)
        XCTAssertFalse(skill.outcomeMilestones.developing.isEmpty)
        XCTAssertFalse(skill.outcomeMilestones.confident.isEmpty)
        XCTAssertFalse(skill.outcomeMilestones.mastered.isEmpty)
    }

    // MARK: - VideoReference Tests

    func testVideoReference() {
        let video = SkillFixtures.testVideo

        XCTAssertEqual(video.id, "test-video-1")
        XCTAssertEqual(video.youtubeId, "abc123")
        XCTAssertNotNil(video.embedURL)
        XCTAssertNotNil(video.thumbnailURL)
        XCTAssertEqual(video.formattedDuration, "5:00")
    }

    func testVideoFormattedDurationVariations() {
        let shortVideo = VideoReference(
            id: "short",
            title: "Short",
            youtubeId: "abc",
            channelName: "Test",
            duration: 45,
            isPrimary: false
        )
        XCTAssertEqual(shortVideo.formattedDuration, "0:45")

        let longVideo = VideoReference(
            id: "long",
            title: "Long",
            youtubeId: "xyz",
            channelName: "Test",
            duration: 3665,
            isPrimary: false
        )
        XCTAssertEqual(longVideo.formattedDuration, "61:05")
    }

    func testVideoEmbedURL() {
        let video = SkillFixtures.testVideo

        let embedURL = video.embedURL
        XCTAssertNotNil(embedURL)
        XCTAssertTrue(embedURL?.absoluteString.contains("youtube.com/embed") ?? false)
    }

    // MARK: - Tip Tests

    func testTipCategories() {
        // Test with actual TipCategory cases
        let focusTip = Tip(id: "t1", title: "Focus", content: "Test", category: .focus, isQuickReference: true)
        let movementTip = Tip(id: "t2", title: "Move", content: "Test", category: .movement, isQuickReference: false)
        let mentalCueTip = Tip(id: "t3", title: "Mental", content: "Test", category: .mentalCue, isQuickReference: true)
        let bodyPosTip = Tip(id: "t4", title: "Body", content: "Test", category: .bodyPosition, isQuickReference: false)

        XCTAssertEqual(focusTip.category, .focus)
        XCTAssertEqual(movementTip.category, .movement)
        XCTAssertEqual(mentalCueTip.category, .mentalCue)
        XCTAssertEqual(bodyPosTip.category, .bodyPosition)
    }

    func testTipCategoryDisplayName() {
        for category in Tip.TipCategory.allCases {
            XCTAssertFalse(category.displayName.isEmpty)
        }
    }

    // MARK: - Drill Tests

    func testDrillTerrain() {
        let drill = SkillFixtures.testDrill

        XCTAssertTrue(drill.recommendedTerrain.contains(.groomedGreen))
        XCTAssertEqual(drill.steps.count, 3)
        XCTAssertEqual(drill.difficulty, .easy)
    }

    func testDrillSteps() {
        let drill = SkillFixtures.testDrill

        XCTAssertEqual(drill.steps[0].order, 1)
        XCTAssertFalse(drill.steps[0].instruction.isEmpty)
    }

    func testDrillDifficultyDisplayName() {
        XCTAssertEqual(Drill.DrillDifficulty.easy.displayName, "Easy")
        XCTAssertEqual(Drill.DrillDifficulty.moderate.displayName, "Moderate")
        XCTAssertEqual(Drill.DrillDifficulty.challenging.displayName, "Challenging")
    }

    // MARK: - Checklist Tests

    func testChecklist() {
        let checklist = SkillFixtures.testChecklist

        XCTAssertEqual(checklist.items.count, 3)
        XCTAssertEqual(checklist.purpose, .preRun)
    }

    func testChecklistItem() {
        let checklist = SkillFixtures.testChecklist

        // Last item should be critical
        let criticalItem = checklist.items.first { $0.isCritical }
        XCTAssertNotNil(criticalItem)
    }
}
