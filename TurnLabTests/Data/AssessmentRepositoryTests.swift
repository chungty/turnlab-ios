import XCTest
import CoreData
@testable import TurnLab

final class AssessmentRepositoryTests: XCTestCase {
    var sut: AssessmentRepository!
    var coreDataStack: CoreDataStack!

    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack.preview
        sut = AssessmentRepository(coreDataStack: coreDataStack)
    }

    override func tearDown() {
        clearAllAssessments()
        sut = nil
        coreDataStack = nil
        super.tearDown()
    }

    // MARK: - Save Assessment Tests

    func testSaveAssessmentCreatesEntity() {
        let assessment = createTestAssessment()

        sut.saveAssessment(assessment)

        let saved = sut.getAllAssessments()
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.skillId, assessment.skillId)
    }

    func testSaveMultipleAssessments() {
        let assessment1 = createTestAssessment(skillId: "skill-1")
        let assessment2 = createTestAssessment(skillId: "skill-2")

        sut.saveAssessment(assessment1)
        sut.saveAssessment(assessment2)

        let saved = sut.getAllAssessments()
        XCTAssertEqual(saved.count, 2)
    }

    // MARK: - Get Assessments Tests

    func testGetAssessmentsForSkillFiltersCorrectly() {
        let assessment1 = createTestAssessment(skillId: "skill-1")
        let assessment2 = createTestAssessment(skillId: "skill-2")
        let assessment3 = createTestAssessment(skillId: "skill-1")

        sut.saveAssessment(assessment1)
        sut.saveAssessment(assessment2)
        sut.saveAssessment(assessment3)

        let skillAssessments = sut.getAssessments(for: "skill-1")

        XCTAssertEqual(skillAssessments.count, 2)
        XCTAssertTrue(skillAssessments.allSatisfy { $0.skillId == "skill-1" })
    }

    func testGetAssessmentsForSkillReturnsEmptyWhenNone() {
        let assessments = sut.getAssessments(for: "non-existent-skill")

        XCTAssertTrue(assessments.isEmpty)
    }

    // MARK: - Get Latest Assessment Tests

    func testGetLatestAssessmentReturnsNewest() {
        let oldDate = Date().addingTimeInterval(-86400) // 1 day ago
        let newDate = Date()

        let oldAssessment = createTestAssessment(skillId: "skill-1", date: oldDate, rating: .needsWork)
        let newAssessment = createTestAssessment(skillId: "skill-1", date: newDate, rating: .confident)

        sut.saveAssessment(oldAssessment)
        sut.saveAssessment(newAssessment)

        let latest = sut.getLatestAssessment(for: "skill-1")

        XCTAssertNotNil(latest)
        XCTAssertEqual(latest?.rating, .confident)
    }

    func testGetLatestAssessmentReturnsNilWhenNone() {
        let latest = sut.getLatestAssessment(for: "non-existent-skill")

        XCTAssertNil(latest)
    }

    // MARK: - Delete Assessment Tests

    func testDeleteAssessmentRemovesEntity() {
        let assessment = createTestAssessment()
        sut.saveAssessment(assessment)

        XCTAssertEqual(sut.getAllAssessments().count, 1)

        sut.deleteAssessment(assessment)

        XCTAssertEqual(sut.getAllAssessments().count, 0)
    }

    // MARK: - Assessment Properties Tests

    func testAssessmentPreservesAllProperties() {
        let assessment = Assessment(
            id: UUID(),
            skillId: "test-skill",
            context: .bumps,
            rating: .developing,
            date: Date(),
            notes: "Test notes"
        )

        sut.saveAssessment(assessment)

        let saved = sut.getAllAssessments().first

        XCTAssertNotNil(saved)
        XCTAssertEqual(saved?.skillId, "test-skill")
        XCTAssertEqual(saved?.context, .bumps)
        XCTAssertEqual(saved?.rating, .developing)
        XCTAssertEqual(saved?.notes, "Test notes")
    }

    // MARK: - Helpers

    private func createTestAssessment(
        skillId: String = "test-skill",
        date: Date = Date(),
        rating: Rating = .confident
    ) -> Assessment {
        Assessment(
            id: UUID(),
            skillId: skillId,
            context: .groomed,
            rating: rating,
            date: date,
            notes: nil
        )
    }

    private func clearAllAssessments() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "AssessmentEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try coreDataStack.viewContext.execute(deleteRequest)
            try coreDataStack.viewContext.save()
        } catch {
            print("Failed to clear assessments: \(error)")
        }
    }
}
