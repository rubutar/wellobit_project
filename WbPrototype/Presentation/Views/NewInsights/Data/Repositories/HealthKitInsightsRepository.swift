import Foundation
import HealthKit

/// Real repository that reads HRV data from HealthKit.
/// Call `prefetchWeek(_:)` async before reading to populate the cache.
final class HealthKitInsightsRepository: InsightsRepositoryProtocol {

    let helper: HealthKitInsightsDataHelper

    init(healthStore: HKHealthStore = HKHealthStore()) {
        self.helper = HealthKitInsightsDataHelper(healthStore: healthStore)
    }

    // MARK: - Async prefetch (call before accessing sync protocol methods)

    func prefetchWeek(_ weekOffset: Int) async {
        await helper.prefetch(weekOffset: weekOffset)
    }

    func prefetchDayWeek(containing date: Date) async {
        guard let offset = helper.weekOffset(containing: date) else { return }
        await helper.prefetch(weekOffset: offset)
    }

    // MARK: - InsightsRepositoryProtocol (synchronous — reads from cache)

    func fetchWeeklyEntries(weekOffset: Int) -> [HRVEntry] {
        helper.buildDailyEntries(weekOffset: weekOffset)
    }

    func fetchDayInsight(for date: Date) -> DayInsight {
        let offset = helper.weekOffset(containing: date) ?? 0
        let entries = helper.buildDailyEntries(weekOffset: offset)
        let avgHRV = entries.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        })?.value ?? 0
        let segments = helper.buildSegments(for: date, weekOffset: offset)
        return DayInsight(id: UUID(), date: date, avgHRV: avgHRV, segments: segments)
    }

    func fetchWeeklySummary(weekOffset: Int) -> InsightsSummary {
        let monday = helper.mondayDate(for: weekOffset) ?? Date()
        let sunday = helper.sundayDate(for: weekOffset) ?? Date()
        let entries = helper.buildDailyEntries(weekOffset: weekOffset)
        let nonZero = entries.filter { $0.value > 0 }
        let avg = nonZero.isEmpty ? 0 : nonZero.map(\.value).reduce(0, +) / nonZero.count

        let prevEntries = helper.buildDailyEntries(weekOffset: weekOffset - 1)
        let prevNonZero = prevEntries.filter { $0.value > 0 }
        let prevAvg = prevNonZero.isEmpty ? 0 : prevNonZero.map(\.value).reduce(0, +) / prevNonZero.count

        let bestEntry = entries.max { $0.value < $1.value }
        let bestDayName: String = {
            guard let entry = bestEntry, entry.value > 0 else { return "-" }
            let f = DateFormatter()
            f.dateFormat = "EEE"
            return f.string(from: entry.date)
        }()

        return InsightsSummary(
            weekStart: monday,
            weekEnd: sunday,
            averageHRV: avg,
            deltaVsLastWeek: avg - prevAvg,
            bestDayName: bestDayName,
            bestDayStatus: bestEntry.map { helper.hrvStatus(from: $0.value) } ?? .low
        )
    }
}
