//
//  FetchTodayRHRUseCaseImpl.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 18/01/26.
//

import Foundation

protocol FetchTodayRHRUseCase {
    func execute() async throws -> Double?
}

final class FetchTodayRHRUseCaseImpl: FetchTodayRHRUseCase {

    private let dataSource: HRVDataSource
    private let calendar: Calendar

    init(dataSource: HRVDataSource, calendar: Calendar = .current) {
        self.dataSource = dataSource
        self.calendar = calendar
    }

    func execute() async throws -> Double? {
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        return try await dataSource.fetchTodayRHR(
            startDate: start,
            endDate: end
        )
    }
}
