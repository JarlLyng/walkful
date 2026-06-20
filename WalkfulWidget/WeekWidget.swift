import WidgetKit
import SwiftUI

struct WeekEntry: TimelineEntry {
    let date: Date
    let week: [Int]   // oldest→newest, last = today
    let goal: Int
    var total: Int { week.reduce(0, +) }
    var average: Int { week.isEmpty ? 0 : total / week.count }
}

struct WeekProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeekEntry {
        WeekEntry(date: .now, week: [5_200, 6_100, 7_400, 6_800, 8_100, 5_600, 4_760], goal: 7_000)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeekEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeekEntry>) -> Void) {
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [currentEntry()], policy: .after(next)))
    }

    private func currentEntry() -> WeekEntry {
        if let snapshot = SharedStore.load() {
            return WeekEntry(date: snapshot.date, week: snapshot.week, goal: snapshot.goal)
        }
        return WeekEntry(date: .now, week: [], goal: 7_000)
    }
}

/// Very-short weekday letters for the `count` days ending at `date` (oldest→newest).
private func weekdayLabels(ending date: Date, count: Int) -> [String] {
    let cal = Calendar.current
    let symbols = cal.veryShortWeekdaySymbols   // index 0 = Sunday
    let today = cal.startOfDay(for: date)
    return (0..<count).reversed().map { offset in
        let day = cal.date(byAdding: .day, value: -offset, to: today) ?? today
        return symbols[cal.component(.weekday, from: day) - 1]
    }
}

struct WeekBarsView: View {
    let week: [Int]
    let goal: Int
    let labels: [String]
    var barHeight: CGFloat = 54
    var showLabels = true

    private var scaleMax: Int { max(week.max() ?? 0, goal, 1) }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(Array(week.enumerated()), id: \.offset) { index, steps in
                VStack(spacing: 3) {
                    ZStack(alignment: .bottom) {
                        Capsule().fill(WidgetBrand.tint.opacity(0.15))
                            .frame(height: barHeight)
                        Capsule()
                            .fill(steps >= goal ? WidgetBrand.tint : WidgetBrand.tint.opacity(0.5))
                            .frame(height: max(3, barHeight * CGFloat(min(steps, scaleMax)) / CGFloat(scaleMax)))
                    }
                    .frame(maxWidth: .infinity)
                    if showLabels {
                        Text(index < labels.count ? labels[index] : "")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct WeekWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: WeekEntry

    private var labels: [String] { weekdayLabels(ending: entry.date, count: entry.week.count) }

    var body: some View {
        switch family {
        case .accessoryRectangular: rectangular
        default: medium
        }
    }

    private var medium: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("This week").font(.caption).foregroundStyle(.secondary)
                    Text("\(entry.total.stepsFormatted) steps")
                        .font(.system(size: 22, weight: .semibold))
                        .minimumScaleFactor(0.7).lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text("avg/day").font(.caption2).foregroundStyle(.secondary)
                    Text(entry.average.stepsFormatted).font(.headline).foregroundStyle(WidgetBrand.tint)
                }
            }
            if entry.week.isEmpty {
                Text("Open Walkful to sync your week.")
                    .font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            } else {
                WeekBarsView(week: entry.week, goal: entry.goal, labels: labels)
            }
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("THIS WEEK").font(.caption2).foregroundStyle(.secondary)
            if entry.week.isEmpty {
                Text("Open Walkful").font(.caption2)
            } else {
                WeekBarsView(week: entry.week, goal: entry.goal, labels: labels,
                             barHeight: 22, showLabels: false)
                Text("\(entry.total.stepsFormatted) steps").font(.caption2)
            }
        }
    }
}

struct WeekWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WalkfulWeekWidget", provider: WeekProvider()) { entry in
            WeekWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("This week")
        .description("Your last 7 days at a glance.")
        .supportedFamilies([.systemMedium, .accessoryRectangular])
    }
}
