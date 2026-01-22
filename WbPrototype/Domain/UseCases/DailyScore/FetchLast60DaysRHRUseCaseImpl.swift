//
//  FetchLast60DaysRHRUseCaseImpl.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 18/01/26.
//

import Foundation

protocol FetchLast60DaysRHRUseCase {
    func execute() async throws -> [Double]
}


final class FetchLast60DaysRHRUseCaseImpl: FetchLast60DaysRHRUseCase {

    private let dataSource: HRVDataSource
    private let calendar: Calendar

    init(dataSource: HRVDataSource, calendar: Calendar = .current) {
        self.dataSource = dataSource
        self.calendar = calendar
    }

    func execute() async throws -> [Double] {
        let end = Date()
        let start = calendar.date(byAdding: .day, value: -60, to: end)!

        return try await dataSource.fetchRHRRange(
            startDate: start,
            endDate: end
        )
    }
}
