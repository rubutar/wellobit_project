//
//  FetchLast30DaysSDNNUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 18/01/26.
//

import Foundation


protocol FetchLast30DaysSDNNUseCase {
    func execute() async throws -> [HRVPoint]
}

final class FetchLast30DaysSDNNUseCaseImpl: FetchLast30DaysSDNNUseCase {

    private let dataSource: HRVDataSource
    private let calendar: Calendar

    init(dataSource: HRVDataSource, calendar: Calendar = .current) {
        self.dataSource = dataSource
        self.calendar = calendar
    }

    func execute() async throws -> [HRVPoint] {
        let end = Date()
        let start = calendar.date(byAdding: .day, value: -30, to: end)!

        return try await dataSource.fetchHRVRange(
            startDate: start,
            endDate: end
        )
    }
}
