import Foundation
import UserNotifications

/// Phase-change cues that reach a locked phone (#174).
///
/// The live haptic in `IntervalCoach` only fires while the app is running, and a
/// phone locked in a pocket, which is the coach's primary use, has suspended the
/// app. So every phase change of the walk is also scheduled as a local
/// notification when the walk starts. The whole walk is known up front: at most
/// 8 rounds, so at most 16 cues, well under iOS's limit of 64 pending.
///
/// In the foreground nothing changes. The app sets no
/// `UNUserNotificationCenterDelegate`, so iOS does not present these while the
/// app is open, and the live haptic stays the cue. Unlocking mid-walk produces
/// no duplicates either: a delivered cue is gone, and the coach deliberately
/// does not buzz for phases it catches up on.
enum CoachCues {

    /// Prefix for every coach request, so the coach and the nudges each clear
    /// their own notifications without touching the other's.
    static let idPrefix = "walkful.coach."

    struct Cue: Equatable {
        enum Kind: Equatable {
            case brisk(round: Int)
            case easy(round: Int)
            case finished
        }
        let kind: Kind
        let fireDate: Date
    }

    /// Every phase change still ahead of the coach's current state. Mirrors
    /// `IntervalCoach.advance(anchoredTo:)` step for step.
    static func plan(phase: IntervalCoach.Phase, currentRound: Int, rounds: Int,
                     phaseEnd: Date, easySeconds: Int, briskSeconds: Int) -> [Cue] {
        var cues: [Cue] = []
        var phase = phase, round = currentRound, end = phaseEnd
        // Bounded, so a malformed plan can never loop: a walk has at most
        // two changes per round.
        for _ in 0...(2 * max(rounds, 1)) {
            switch phase {
            case .easy:
                cues.append(Cue(kind: .brisk(round: round), fireDate: end))
                phase = .brisk
                end = end.addingTimeInterval(TimeInterval(briskSeconds))
            case .brisk:
                if round >= rounds {
                    cues.append(Cue(kind: .finished, fireDate: end))
                    return cues
                }
                round += 1
                cues.append(Cue(kind: .easy(round: round), fireDate: end))
                phase = .easy
                end = end.addingTimeInterval(TimeInterval(easySeconds))
            }
        }
        return cues
    }

    /// Of the pending identifiers, the ones that are not the coach's.
    /// `NudgeScheduler` clears exactly these, which keeps its cleanup of the
    /// pre-1.0.4 clock nudges while leaving a walk in progress alone.
    static func identifiersNotOwnedByCoach(_ ids: [String]) -> [String] {
        ids.filter { !$0.hasPrefix(idPrefix) }
    }
}

/// Where the coach's cues go. Injected so tests never touch the real
/// notification center, where an unanswered permission prompt would hang the run.
@MainActor
protocol CueScheduling {
    /// Replaces any pending coach cues with these. Returns false when
    /// notifications are not allowed, so the coach can say why cues are missing.
    func replace(with cues: [CoachCues.Cue], totalRounds: Int, briskMinutes: Int) async -> Bool
    func removeAll() async
}

@MainActor
struct SystemCueScheduler: CueScheduling {

    /// Stateless, so it can be made anywhere, including as a default argument,
    /// which Swift evaluates outside the main actor.
    nonisolated init() {}

    private var center: UNUserNotificationCenter { .current() }

    func replace(with cues: [CoachCues.Cue], totalRounds: Int, briskMinutes: Int) async -> Bool {
        await removeAll()
        guard await isAllowed() else { return false }

        for (index, cue) in cues.enumerated() {
            let delay = cue.fireDate.timeIntervalSinceNow
            guard delay > 0.5 else { continue }

            // Every string here already exists on the coach screen, so the
            // cues read exactly like the app and are already translated.
            let content = UNMutableNotificationContent()
            switch cue.kind {
            case .brisk(let round):
                content.title = String(localized: IntervalCoach.Phase.brisk.title)
                content.body = String(localized: "Round \(round) of \(totalRounds)")
            case .easy(let round):
                content.title = String(localized: IntervalCoach.Phase.easy.title)
                content.body = String(localized: "Round \(round) of \(totalRounds)")
            case .finished:
                content.title = String(localized: "Nice walk!")
                content.body = String(localized: "You completed \(totalRounds) brisk intervals, about \(briskMinutes) brisk minutes. Every step counts.")
            }
            content.sound = .default          // vibrates and sounds in a pocket
            content.threadIdentifier = "walkful.coach"

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
            let request = UNNotificationRequest(identifier: CoachCues.idPrefix + String(index),
                                                content: content, trigger: trigger)
            try? await center.add(request)
        }
        return true
    }

    func removeAll() async {
        let pending = await center.pendingNotificationRequests()
        let ours = pending.map(\.identifier).filter { $0.hasPrefix(CoachCues.idPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: ours)
    }

    private func isAllowed() async -> Bool {
        var status = await center.notificationSettings().authorizationStatus
        if status == .notDetermined {
            // Someone who never turned nudges on has never been asked. Their
            // first walk is the moment a cue is wanted, so ask here.
            _ = await NudgeScheduler.requestAuthorization()
            status = await center.notificationSettings().authorizationStatus
        }
        switch status {
        case .authorized, .provisional, .ephemeral: return true
        default: return false
        }
    }
}
