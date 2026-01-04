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
        XCTAssertEqual(TerrainContext.allCases.count, 4)
    }

    func testTerrainContextDisplayName() {
        XCTAssertFalse(TerrainContext.groomed.displayName.isEmpty)
        XCTAssertFalse(TerrainContext.bumps.displayName.isEmpty)
    }

    // MARK: - Skill Tests

    func testSkillCreation() {
        let skill = SkillFixtures.beginnerSkill

        XCTAssertEqual(skill.id, "test-beginner-skill")
        XCTAssertEqual(skill.level, .beginner)
        XCTAssertEqual(skill.domain, .balance)
        XCTAssertFalse(skill.milestones.isEmpty)
    }

    func testSkillContent() {
        let skill = SkillFixtures.expertSkill

        XCTAssertFalse(skill.content.videos.isEmpty)
        XCTAssertFalse(skill.content.tips.isEmpty)
        XCTAssertFalse(skill.content.drills.isEmpty)
        XCTAssertFalse(skill.content.checklists.isEmpty)
        XCTAssertFalse(skill.content.warnings.isEmpty)
    }

    // MARK: - VideoReference Tests

    func testVideoReference() {
        let video = SkillFixtures.testVideo

        XCTAssertEqual(video.id, "test-video-1")
        XCTAssertEqual(video.youtubeId, "abc123")
        XCTAssertFalse(video.embedUrl.isEmpty)
        XCTAssertFalse(video.thumbnailUrl.isEmpty)
        XCTAssertEqual(video.formattedDuration, "5:00")
    }

    func testVideoFormattedDurationVariations() {
        let shortVideo = VideoReference(
            id: "short",
            title: "Short",
            youtubeId: "abc",
            channelName: "Test",
            durationSeconds: 45,
            description: "Short video"
        )
        XCTAssertEqual(shortVideo.formattedDuration, "0:45")

        let longVideo = VideoReference(
            id: "long",
            title: "Long",
            youtubeId: "xyz",
            channelName: "Test",
            durationSeconds: 3665,
            description: "Long video"
        )
        XCTAssertEqual(longVideo.formattedDuration, "61:05")
    }

    // MARK: - Tip Tests

    func testTipCategories() {
        let techniqueTip = Tip(id: "t1", content: "Test", category: .technique)
        let safetyTip = Tip(id: "t2", content: "Test", category: .safety)
        let feelTip = Tip(id: "t3", content: "Test", category: .feel)
        let equipmentTip = Tip(id: "t4", content: "Test", category: .equipment)

        XCTAssertEqual(techniqueTip.category, .technique)
        XCTAssertEqual(safetyTip.category, .safety)
        XCTAssertEqual(feelTip.category, .feel)
        XCTAssertEqual(equipmentTip.category, .equipment)
    }

    // MARK: - Drill Tests

    func testDrillTerrain() {
        let drill = SkillFixtures.testDrill

        XCTAssertEqual(drill.terrain, .groomed)
        XCTAssertEqual(drill.durationMinutes, 10)
        XCTAssertEqual(drill.steps.count, 3)
    }
}
