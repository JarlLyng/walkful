import XCTest
@testable import Walkful

@MainActor
final class IntervalCoachTests: XCTestCase {

    /// Zero-length phases let a single tick exercise the whole catch-up loop —
    /// the same path that runs after the phone was locked mid-session (#83).
    func testElapsedPhasesAreCaughtUpAndSessionFinishes() {
        let coach = IntervalCoach()
        coach.rounds = 2
        coach.easySeconds = 0
        coach.briskSeconds = 0
        coach.start()
        coach.tick()
        XCTAssertTrue(coach.isFinished)
        XCTAssertFalse(coach.isRunning)
        XCTAssertEqual(coach.remaining, 0)
    }

    func testCatchUpLandsInTheCorrectMidSessionPhase() {
        let coach = IntervalCoach()
        coach.rounds = 2
        coach.easySeconds = 0      // already elapsed at start
        coach.briskSeconds = 3_600 // far in the future
        coach.start()
        coach.tick()
        XCTAssertEqual(coach.phase, .brisk)
        XCTAssertEqual(coach.currentRound, 1)
        XCTAssertFalse(coach.isFinished)
        XCTAssertGreaterThanOrEqual(coach.remaining, 3_599)
    }

    func testPauseFreezesRemainingAndTicksDoNothing() {
        let coach = IntervalCoach()
        coach.start()
        coach.togglePause()
        XCTAssertFalse(coach.isRunning)
        let frozen = coach.remaining
        coach.tick()
        XCTAssertEqual(coach.remaining, frozen)
        coach.togglePause()
        XCTAssertTrue(coach.isRunning)
    }

    func testStopResetsSession() {
        let coach = IntervalCoach()
        coach.start()
        coach.stop()
        XCTAssertFalse(coach.hasStarted)
        XCTAssertFalse(coach.isRunning)
        XCTAssertFalse(coach.isFinished)
    }
}
