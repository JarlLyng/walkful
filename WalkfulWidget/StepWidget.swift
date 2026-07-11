import WidgetKit
import SwiftUI
import UIKit

// Brand tint — purple in light, lime in dark (matches IAMJARL).
enum WidgetBrand {
    static let tint = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.816, green: 1.0, blue: 0.0, alpha: 1)   // #D0FF00
            : UIColor(red: 0.643, green: 0.208, blue: 0.824, alpha: 1) // #A435D2
    })
}

struct StepEntry: TimelineEntry {
    let date: Date
    let steps: Int
    let goal: Int
    var progress: Double { goal > 0 ? min(Double(steps) / Double(goal), 1) : 0 }
}

struct StepProvider: TimelineProvider {
    func placeholder(in context: Context) -> StepEntry {
        StepEntry(date: .now, steps: 4_760, goal: 7_000)
    }

    func getSnapshot(in context: Context, completion: @escaping (StepEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StepEntry>) -> Void) {
        let cal = Calendar.current
        let now = Date()
        var entries = [currentEntry()]
        // Reset to 0 at midnight so the ring doesn't keep showing today's count
        // as "today" once the day rolls over and the app hasn't run yet.
        if let midnight = cal.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) {
            entries.append(StepEntry(date: midnight, steps: 0, goal: entries[0].goal))
        }
        let next = cal.date(byAdding: .minute, value: 30, to: now) ?? now
        completion(Timeline(entries: entries, policy: .after(next)))
    }

    private func currentEntry() -> StepEntry {
        // A snapshot from a previous day is stale — show 0 for today, not
        // yesterday's count (#85). Keep the user's goal if we have one.
        if let snapshot = SharedStore.load() {
            let steps = snapshot.isFromToday() ? snapshot.steps : 0
            return StepEntry(date: .now, steps: steps, goal: snapshot.goal)
        }
        return StepEntry(date: .now, steps: 0, goal: 7_000)
    }
}

struct StepWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: StepEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: entry.progress) {
                Image(systemName: "figure.walk")
            } currentValueLabel: {
                Text("\(Int(entry.progress * 100))")
            }
            .gaugeStyle(.accessoryCircular)
            .tint(WidgetBrand.tint)

        case .accessoryInline:
            Text("\(entry.steps.stepsFormatted) steps")

        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text("WALKFUL").font(.caption2).foregroundStyle(.secondary)
                Text("\(entry.steps.stepsFormatted) steps").font(.headline)
                Gauge(value: entry.progress) { EmptyView() }
                    .gaugeStyle(.accessoryLinearCapacity)
                    .tint(WidgetBrand.tint)
            }

        default: // systemSmall
            small
        }
    }

    private var small: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().stroke(WidgetBrand.tint.opacity(0.2), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(WidgetBrand.tint, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 1) {
                    Text(entry.steps.stepsFormatted)
                        .font(.system(size: 20, weight: .semibold))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    Text("of \(entry.goal.stepsFormatted)")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(4)
    }
}

struct StepWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WalkfulStepWidget", provider: StepProvider()) { entry in
            StepWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Steps")
        .description("Your step progress today.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}
