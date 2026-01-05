import XCTest
import CoreData
@testable import TurnLab

/// Placeholder tests for AssessmentRepository.
/// TODO: Update tests to match async repository protocol.
final class AssessmentRepositoryTests: XCTestCase {
    var sut: AssessmentRepository!
    var coreDataStack: CoreDataStack!

    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack.preview
        sut = AssessmentRepository(coreDataStack: coreDataStack)
    }

    override func tearDown() {
        sut = nil
        coreDataStack = nil
        super.tearDown()
    }

    // MARK: - Basic Tests

    func testRepositoryInitializes() {
        XCTAssertNotNil(sut)
    }

    @MainActor
    func testGetAllAssessmentsReturnsArray() async {
        let assessments = await sut.getAllAssessments()
        XCTAssertNotNil(assessments)
    }

    @MainActor
    func testGetAssessmentsForSkillReturnsArray() async {
        let assessments = await sut.getAssessments(for: "test-skill")
        XCTAssertNotNil(assessments)
    }

    @MainActor
    func testGetBestRatingReturnsNotAssessedForNewSkill() async {
        let rating = await sut.getBestRating(for: "unknown-skill-id")
        XCTAssertEqual(rating, .notAssessed)
    }
}
