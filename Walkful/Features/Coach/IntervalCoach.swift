import Foundation
import Observation

/// Drives a guided interval walk: alternating "easy" and "brisk" phases for a
/// number of rounds, with haptic cues on each phase change. Entirely on-device —
/// nothing is written to Apple Health. Grounded in Bente Klarlund Pedersen's
/// advice that brisk interval walking meaningfully improves fitness.
///
/// Timing is anchored to the wall clock, not counted down per timer tick:
/// SwiftUI stops delivering ticks while the app is backgrounded or the screen
/// is locked (phone-in-pocket is the primary use), so `remaining` is always
/// derived from the current phase's end `Date`. On the next tick after unlock,
/// any phases that fully elapsed in the meantime are caught up.
@MainActor
@Observable
final class IntervalCoach {

    enum Phase {
        case easy, brisk
        var title: String { self == .brisk ? "Brisk" : "Easy" }
    }

    // Plan (seconds)
    var rounds = 4
    var easySeconds = 180
    var briskSeconds = 180

    private(set) var hasStarted = false
    private(set) var isRunning = false
    private(set) var isFinished = false
    private(set) var currentRound = 1
    private(set) var phase: Phase = .easy
    private(set) var remaining = 0

    /// Wall-clock end of the current phase. nil while paused/stopped —
    /// `remaining` then holds the frozen value.
    private var phaseEnd: Date?

    var phaseTotal: Int { phase == .brisk ? briskSeconds : easySeconds }
    var phaseProgress: Double {
        phaseTotal > 0 ? Double(phaseTotal - remaining) / Double(phaseTotal) : 0
    }
    var briskMinutes: Int { rounds * briskSeconds / 60 }

    func start() {
        currentRound = 1
        phase = .easy
        remaining = easySeconds
        phaseEnd = Date.now.addingTimeInterval(TimeInterval(easySeconds))
        hasStarted = true
        isFinished = false
        isRunning = true
        impact()
    }

    func togglePause() {
        if isRunning {
            remaining = currentRemaining()   // freeze
            phaseEnd = nil
            isRunning = false
        } else {
            phaseEnd = Date.now.addingTimeInterval(TimeInterval(remaining))
            isRunning = true
        }
    }

    #if DEBUG
    /// Puts the coach in a representative mid-session state for screenshots.
    func setScreenshotState() {
        rounds = 4
        currentRound = 2
        phase = .brisk
        remaining = 108
        phaseEnd = Date.now.addingTimeInterval(108)
        hasStarted = true
        isFinished = false
        isRunning = true
    }
    #endif

    func stop() {
        isRunning = false
        isFinished = false
        hasStarted = false
        phaseEnd = nil
    }

    /// Called once per second by the view's timer, and when the scene becomes
    /// active again. Derives `remaining` from the wall clock and advances any
    /// phases that fully elapsed while ticks weren't delivered.
    func tick() {
        guard isRunning, !isFinished else { return }
        while let end = phaseEnd, end <= Date.now, !isFinished {
            advance(anchoredTo: end)
        }
        guard !isFinished else { return }
        remaining = currentRemaining()
    }

    private func currentRemaining() -> Int {
        guard let end = phaseEnd else { return remaining }
        return max(0, Int(end.timeIntervalSinceNow.rounded(.up)))
    }

    private func advance(anchoredTo end: Date) {
        // Only buzz for transitions happening "live" — when catching up on
        // several phases that elapsed in the background, a burst of stale
        // haptics on unlock would be noise, not guidance.
        let isLive = abs(end.timeIntervalSinceNow) < 2

        switch phase {
        case .easy:
            phase = .brisk
            remaining = briskSeconds
            phaseEnd = end.addingTimeInterval(TimeInterval(briskSeconds))
            if isLive { impact() }
        case .brisk:
            if currentRound >= rounds {
                finish()
            } else {
                currentRound += 1
                phase = .easy
                remaining = easySeconds
                phaseEnd = end.addingTimeInterval(TimeInterval(easySeconds))
                if isLive { impact() }
            }
        }
    }

    private func finish() {
        isRunning = false
        isFinished = true
        remaining = 0
        phaseEnd = nil
        success()
    }

    // MARK: - Haptics

    private func impact() { Haptics.impact() }
    private func success() { Haptics.success() }
}
