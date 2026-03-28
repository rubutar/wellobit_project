import Foundation

/// Contract for fetching insights data.
/// Swap `DummyInsightsRepository` for a real Apple Watch / HealthKit repository later.
protocol InsightsRepositoryProtocol {
    func fetchWeeklyEntries(weekOffset: Int) -> [HRVEntry]
    func fetchDayInsight(for date: Date) -> DayInsight
    func fetchWeeklySummary(weekOffset: Int) -> InsightsSummary
}
