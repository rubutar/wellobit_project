import Foundation

/// Provides static dummy HRV data.
/// Replace with a HealthKit / Apple Watch repository when ready.
final class DummyInsightsRepository: InsightsRepositoryProtocol {

    // MARK: - Dummy data sets (one per week, cycled)

    private let weeklyDataSets: [(values: [Int], qualities: [HRVQuality])] = [
        (
            values:    [0, 30, 0, 30, 30, 30, 30],
            qualities: [.low, .low, .recovery, .balanced, .recovery, .good, .balanced]
        ),
        (
            values:    [30, 30, 30, 30, 30, 30, 30],
            qualities: [.low, .recovery, .recovery, .balanced, .balanced, .low, .recovery]
        ),
        (
            values:    [30, 30, 30, 30, 30, 30, 30],
            qualities: [.low, .good, .recovery, .balanced, .good, .low, .recovery]
        ),
        (
            values:    [30, 30, 30, 30, 30, 30, 30],
            qualities: [.low, .recovery, .recovery, .good, .balanced, .good, .recovery]
        ),
    ]

    private let daySegments: [(TimeOfDaySegment, HRVStatusNew)] = [
        (.earlyMorning, .good),
        (.morning,      .recovery),
        (.afternoon,    .balanced),
        (.evening,      .low)
    ]

    // MARK: - InsightsRepositoryProtocol

    func fetchWeeklyEntries(weekOffset: Int) -> [HRVEntry] {
        guard let monday = monday(for: weekOffset) else { return [] }
        let index = abs(weekOffset) % weeklyDataSets.count
        let dataSet = weeklyDataSets[index]
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return (0..<7).compactMap { dayIndex in
            guard let date = calendar.date(byAdding: .day, value: dayIndex, to: monday) else { return nil }
            return HRVEntry(
                id: UUID(),
                date: date,
                value: dataSet.values[dayIndex],
                quality: dataSet.qualities[dayIndex]
            )
        }
    }

    func fetchDayInsight(for date: Date) -> DayInsight {
        let segments = daySegments.map { seg in
            TimeOfDayInsight(id: UUID(), segment: seg.0, status: seg.1)
        }
        return DayInsight(id: UUID(), date: date, avgHRV: 27, segments: segments)
    }

    func fetchWeeklySummary(weekOffset: Int) -> InsightsSummary {
        let entries = fetchWeeklyEntries(weekOffset: weekOffset)
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        let weekStart = monday(for: weekOffset) ?? Date()
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? Date()

        let nonZero = entries.filter { $0.value > 0 }
        let average = nonZero.isEmpty ? 0 : nonZero.map(\.value).reduce(0, +) / nonZero.count

        let bestEntry = entries.max(by: { $0.value < $1.value })
        let bestDayName: String = {
            guard let entry = bestEntry else { return "-" }
            let f = DateFormatter()
            f.dateFormat = "EEE"
            return f.string(from: entry.date)
        }()

        let deltas = [3, -2, 5, 1, -3, 4, 2]
        let delta = deltas[abs(weekOffset) % deltas.count]

        return InsightsSummary(
            weekStart: weekStart,
            weekEnd: weekEnd,
            averageHRV: average,
            deltaVsLastWeek: delta,
            bestDayName: bestDayName,
            bestDayStatus: .balanced
        )
    }

    // MARK: - Helpers

    private func monday(for weekOffset: Int) -> Date? {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        let today = Date()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        guard let currentMonday = calendar.date(from: components) else { return nil }
        return calendar.date(byAdding: .weekOfYear, value: weekOffset, to: currentMonday)
    }
}
