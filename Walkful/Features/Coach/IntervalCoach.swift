import Foundation
import Observation

/// Drives a guided interval walk: alternating "easy" and "brisk" phases for a
/// number of rounds, with haptic cues on each phase change. Entirely on-device —
/// nothing is written to Apple Health. Grounded in Bente Klarlund Pedersen's
/// advice that brisk interval walking meaningfully improves fitness.
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

    var phaseTotal: Int { phase == .brisk ? briskSeconds : easySeconds }
    var phaseProgress: Double {
        phaseTotal > 0 ? Double(phaseTotal - remaining) / Double(phaseTotal) : 0
    }
    var briskMinutes: Int { rounds * briskSeconds / 60 }

    func start() {
        currentRound = 1
        phase = .easy
        remaining = easySeconds
        hasStarted = true
        isFinished = false
        isRunning = true
        impact()
    }

    func togglePause() { isRunning.toggle() }

    func stop() {
        isRunning = false
        isFinished = false
        hasStarted = false
    }

    /// Called once per second by the view's timer.
    func tick() {
        guard isRunning, !isFinished else { return }
        if remaining > 1 {
            remaining -= 1
        } else {
            advance()
        }
    }

    private func advance() {
        switch phase {
        case .easy:
            phase = .brisk
            remaining = briskSeconds
            impact()
        case .brisk:
            if currentRound >= rounds {
                finish()
            } else {
                currentRound += 1
                phase = .easy
                remaining = easySeconds
                impact()
            }
        }
    }

    private func finish() {
        isRunning = false
        isFinished = true
        remaining = 0
        success()
    }

    // MARK: - Haptics

    private func impact() { Haptics.impact() }
    private func success() { Haptics.success() }
}
