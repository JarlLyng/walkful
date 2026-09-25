import XCTest
@testable import Walkful

/// Records what the coach asks of the notification layer, so the wiring can be
/// tested without the real notification center.
@MainActor
final class RecordingCues: CueScheduling {
    enum Call: Equatable { case replace(count: Int), removeAll }
    private(set) var calls: [Call] = []
    private(set) var lastPlan: [CoachCues.Cue] = []
    var allow = true

    func replace(with cues: [CoachCues.Cue], totalRounds: Int, briskMinutes: Int) async -> Bool {
        calls.append(.replace(count: cues.count))
        lastPlan = cues
        return allow
    }

    func removeAll() async { calls.append(.removeAll) }
}

/// #174: a phone locked in a pocket must still be told when to switch pace.
@MainActor
final class CoachCuesTests: XCTestCase {

    private let t0 = Date(timeIntervalSince1970: 1_000_000)

    // MARK: - The plan

    func testAFullWalkPlansTwoCuesPerRoundEndingInTheFinish() {
        let cues = CoachCues.plan(phase: .easy, currentRound: 1, rounds: 3,
                                  phaseEnd: t0, easySeconds: 180, briskSeconds: 180)
        XCTAssertEqual(cues.map(\.kind), [
            .brisk(round: 1), .easy(round: 2), .brisk(round: 2),
            .easy(round: 3), .brisk(round: 3), .finished,
        ])
        XCTAssertEqual(cues.map { $0.fireDate.timeIntervalSince(t0) },
                       [0, 180, 360, 540, 720, 900])
    }

    func testTheLongestWalkStaysWellUnderTheSystemLimit() {
        let cues = CoachCues.plan(phase: .easy, currentRound: 1, rounds: 8,
                                  phaseEnd: t0, easySeconds: 180, briskSeconds: 180)
        XCTAssertEqual(cues.count, 16)
        XCTAssertLessThanOrEqual(cues.count, 64)
    }

    /// After a resume the plan starts from wherever the walk is, not from round one.
    func testAPlanFromMidWalkCoversOnlyWhatIsLeft() {
        let cues = CoachCues.plan(phase: .brisk, currentRound: 2, rounds: 4,
                                  phaseEnd: t0, easySeconds: 180, briskSeconds: 180)
        XCTAssertEqual(cues.map(\.kind), [
            .easy(round: 3), .brisk(round: 3), .easy(round: 4), .brisk(round: 4), .finished,
        ])
    }

    func testTheLastBriskPhasePlansOnlyTheFinish() {
        let cues = CoachCues.plan(phase: .brisk, currentRound: 4, rounds: 4,
                                  phaseEnd: t0, easySeconds: 180, briskSeconds: 180)
        XCTAssertEqual(cues.map(\.kind), [.finished])
    }

    // MARK: - The nudges leave the coach alone

    func testNudgeCleanupClearsEverythingExceptTheCoachsCues() {
        let pending = ["walkful.sedentary.ABC", "walkful.coach.0", "walkful.coach.7",
                       "baseline.11", "baseline.15"]
        XCTAssertEqual(CoachCues.identifiersNotOwnedByCoach(pending),
                       ["walkful.sedentary.ABC", "baseline.11", "baseline.15"])
    }

    // MARK: - The coach's lifecycle

    func testStartingAWalkSchedulesEveryPhaseChange() async {
        let recorder = RecordingCues()
        let coach = IntervalCoach(cues: recorder)
        coach.rounds = 4
        coach.start()
        await coach.cueTask?.value
        XCTAssertEqual(recorder.calls, [.replace(count: 8)])
    }

    /// Order matters: a pause right after start must end with nothing pending.
    func testPausingRightAfterStartLeavesNothingBehind() async {
        let recorder = RecordingCues()
        let coach = IntervalCoach(cues: recorder)
        coach.start()
        coach.togglePause()
        await coach.cueTask?.value
        XCTAssertEqual(recorder.calls, [.replace(count: 8), .removeAll])
    }

    func testResumingSchedulesTheRestFromTheNewPhaseEnd() async {
        let recorder = RecordingCues()
        let coach = IntervalCoach(cues: recorder)
        coach.start()
        coach.togglePause()
        coach.togglePause()
        await coach.cueTask?.value
        XCTAssertEqual(recorder.calls.last, .replace(count: 8))
        let firstCue = try? XCTUnwrap(recorder.lastPlan.first)
        XCTAssertEqual(firstCue?.kind, .brisk(round: 1))
        XCTAssertGreaterThan(firstCue?.fireDate ?? .distantPast, Date.now)
    }

    func testStoppingRemovesTheCues() async {
        let recorder = RecordingCues()
        let coach = IntervalCoach(cues: recorder)
        coach.start()
        coach.stop()
        await coach.cueTask?.value
        XCTAssertEqual(recorder.calls.last, .removeAll)
    }

    func testFinishingRemovesAnyCuesStillPending() async {
        let recorder = RecordingCues()
        let coach = IntervalCoach(cues: recorder)
        coach.rounds = 2
        coach.easySeconds = 0
        coach.briskSeconds = 0
        coach.start()
        coach.tick()
        await coach.cueTask?.value
        XCTAssertTrue(coach.isFinished)
        XCTAssertEqual(recorder.calls.last, .removeAll)
    }

    func testTheCoachSaysSoWhenNotificationsAreOff() async {
        let recorder = RecordingCues()
        recorder.allow = false
        let coach = IntervalCoach(cues: recorder)
        coach.start()
        await coach.cueTask?.value
        XCTAssertTrue(coach.cuesUnavailable)
    }
}
