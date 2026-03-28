import Foundation
import HealthKit

/// Fetches HRV data from HealthKit and caches it per week offset.
/// The repository reads from this cache synchronously; call `prefetch(_:)` async first.
final class HealthKitInsightsDataHelper {

    private let dataSource: HRVDataSource
    // Cached raw HRV points keyed by weekOffset
    private var pointsCache: [Int: [HRVPoint]] = [:]

    init(healthStore: HKHealthStore) {
        self.dataSource = HealthKitHRVDataSource(healthStore: healthStore)
    }

    // MARK: - Async prefetch

    /// Fetches all SDNN points for the given week and stores them in cache.
    /// Call this from an async context before reading via the sync accessors below.
    func prefetch(weekOffset: Int) async {
        guard let monday = mondayDate(for: weekOffset) else { return }
        let endOfSunday = endOfWeek(after: monday)
        let points = (try? await dataSource.fetchHRVRange(startDate: monday, endDate: endOfSunday)) ?? []
        pointsCache[weekOffset] = points
    }

    // MARK: - Sync accessors (read from cache)

    func cachedPoints(weekOffset: Int) -> [HRVPoint] {
        pointsCache[weekOffset] ?? []
    }

    // MARK: - Domain builders

    /// One `HRVEntry` per day of the week using cached data.
    func buildDailyEntries(weekOffset: Int) -> [HRVEntry] {
        guard let monday = mondayDate(for: weekOffset) else { return [] }
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let points = cachedPoints(weekOffset: weekOffset)

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else { return nil }
            let dayPoints = points.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let avg = dayPoints.isEmpty ? 0 : Int(dayPoints.map(\.value).reduce(0, +) / Double(dayPoints.count))
            return HRVEntry(id: UUID(), date: date, value: avg, quality: hrvQuality(from: avg))
        }
    }

    /// Per-hour segment insights for a single day using cached data for its week.
    func buildSegments(for date: Date, weekOffset: Int) -> [TimeOfDayInsight] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let points = cachedPoints(weekOffset: weekOffset)
        let dayPoints = points.filter { calendar.isDate($0.date, inSameDayAs: date) }

        return TimeOfDaySegment.allCases.compactMap { segment in
            let segmentPoints = dayPoints.filter { timeSegment(for: $0.date) == segment }
            guard !segmentPoints.isEmpty else { return nil }
            let avg = Int(segmentPoints.map(\.value).reduce(0, +) / Double(segmentPoints.count))
            return TimeOfDayInsight(id: UUID(), segment: segment, status: hrvStatus(from: avg))
        }
    }

    // MARK: - Calendar helpers

    func mondayDate(for weekOffset: Int) -> Date? {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        guard let currentMonday = calendar.date(from: components) else { return nil }
        return calendar.date(byAdding: .weekOfYear, value: weekOffset, to: currentMonday)
    }

    func sundayDate(for weekOffset: Int) -> Date? {
        guard let monday = mondayDate(for: weekOffset) else { return nil }
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar.date(byAdding: .day, value: 6, to: monday)
    }

    func weekOffset(containing date: Date) -> Int? {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        guard
            let thisMonday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())),
            let targetMonday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))
        else { return nil }
        return calendar.dateComponents([.weekOfYear], from: thisMonday, to: targetMonday).weekOfYear
    }

    // MARK: - HRV classification (SDNN in ms)

    func hrvQuality(from sdnn: Int) -> HRVQuality {
        switch sdnn {
        case 50...: return .good
        case 35..<50: return .balanced
        case 20..<35: return .recovery
        default: return .low
        }
    }

    func hrvStatus(from sdnn: Int) -> HRVStatusNew {
        switch sdnn {
        case 50...: return .good
        case 35..<50: return .balanced
        case 20..<35: return .recovery
        default: return .low
        }
    }

    // MARK: - Private helpers

    private func endOfWeek(after monday: Date) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday) ?? monday
        return calendar.date(byAdding: .day, value: 1, to: sunday) ?? sunday
    }

    private func timeSegment(for date: Date) -> TimeOfDaySegment {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 0..<4:  return .earlyMorning
        case 4..<9:  return .morning
        case 9..<17: return .afternoon
        default:     return .evening
        }
    }
}
