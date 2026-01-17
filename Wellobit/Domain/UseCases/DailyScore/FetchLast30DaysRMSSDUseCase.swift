protocol FetchLast30DaysRMSSDUseCase {
    func execute() async throws -> [HRVPoint]
}

final class FetchLast30DaysRMSSDUseCaseImpl: FetchLast30DaysRMSSDUseCase {

    private let dataSource: HRVDataSource
    private let calendar: Calendar

    init(dataSource: HRVDataSource, calendar: Calendar = .current) {
        self.dataSource = dataSource
        self.calendar = calendar
    }

    func execute() async throws -> [HRVPoint] {
        let end = Date()
        let start = calendar.date(byAdding: .day, value: -30, to: end)!

        return try await dataSource.fetchRMSSDRange(
            startDate: start,
            endDate: end
        )
    }
}
