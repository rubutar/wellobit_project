import Foundation

/// Retrieves insights data through the repository abstraction.
final class GetInsightsUseCase {
    private let repository: InsightsRepositoryProtocol

    init(repository: InsightsRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Async prefetch (call before reading to ensure real data is loaded)

    func prefetchWeek(_ weekOffset: Int) async {
        if let real = repository as? HealthKitInsightsRepository {
            await real.prefetchWeek(weekOffset)
        }
    }

    func prefetchDayWeek(containing date: Date) async {
        if let real = repository as? HealthKitInsightsRepository {
            await real.prefetchDayWeek(containing: date)
        }
    }

    // MARK: - Sync reads (from cache after prefetch)

    func weeklyEntries(weekOffset: Int) -> [HRVEntry] {
        repository.fetchWeeklyEntries(weekOffset: weekOffset)
    }

    func dayInsight(for date: Date) -> DayInsight {
        repository.fetchDayInsight(for: date)
    }

    func weeklySummary(weekOffset: Int) -> InsightsSummary {
        repository.fetchWeeklySummary(weekOffset: weekOffset)
    }
}
