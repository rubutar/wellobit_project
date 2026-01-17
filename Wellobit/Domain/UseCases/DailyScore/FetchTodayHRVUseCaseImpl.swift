final class FetchTodayHRVUseCaseImpl: FetchTodayHRVUseCase {

    private let hrvDataSource: HRVDataSource
    private let calendar: Calendar

    init(
        hrvDataSource: HRVDataSource,
        calendar: Calendar = .current
    ) {
        self.hrvDataSource = hrvDataSource
        self.calendar = calendar
    }

    func execute() async throws -> [HRVPoint] {
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        return try await hrvDataSource.fetchTodayHRV(
            startDate: start,
            endDate: end
        )
    }
}
