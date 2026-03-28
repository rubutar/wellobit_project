import Foundation
import Combine

@MainActor
final class InsightsViewModel: ObservableObject {

    // MARK: - Published state

    @Published var selectedPeriod: InsightPeriod = .weekly
    @Published var entries: [HRVEntry] = []
    @Published var selectedDayInsight: DayInsight?
    @Published var selectedEntryId: UUID?
    @Published var summary: InsightsSummary?
    @Published var isDayDetailExpanded: Bool = true
    @Published var isLoading: Bool = false

    // MARK: - Private

    private(set) var weekOffset: Int = 0
    private let getInsightsUseCase: GetInsightsUseCase

    var canGoToNextWeek: Bool { weekOffset < 0 }

    // MARK: - Init

    init(getInsightsUseCase: GetInsightsUseCase) {
        self.getInsightsUseCase = getInsightsUseCase
        loadData()
    }

    // MARK: - Public actions

    func previousWeek() {
        weekOffset -= 1
        loadData()
    }

    func nextWeek() {
        guard canGoToNextWeek else { return }
        weekOffset += 1
        loadData()
    }

    func selectEntry(_ entry: HRVEntry) {
        selectedEntryId = entry.id
        Task {
            await getInsightsUseCase.prefetchDayWeek(containing: entry.date)
            selectedDayInsight = getInsightsUseCase.dayInsight(for: entry.date)
        }
    }

    func toggleDayDetail() {
        isDayDetailExpanded.toggle()
    }

    // MARK: - Private

    private func loadData() {
        let offset = weekOffset
        isLoading = true
        Task {
            await getInsightsUseCase.prefetchWeek(offset)
            // Also prefetch previous week for delta calculation
            await getInsightsUseCase.prefetchWeek(offset - 1)
            refreshUI(weekOffset: offset)
            isLoading = false
        }
    }

    private func refreshUI(weekOffset: Int) {
        entries = getInsightsUseCase.weeklyEntries(weekOffset: weekOffset)
        summary = getInsightsUseCase.weeklySummary(weekOffset: weekOffset)
        let firstWithData = entries.first(where: { $0.value > 0 }) ?? entries.first
        if let first = firstWithData {
            selectedDayInsight = getInsightsUseCase.dayInsight(for: first.date)
            selectedEntryId = first.id
        }
    }
}
