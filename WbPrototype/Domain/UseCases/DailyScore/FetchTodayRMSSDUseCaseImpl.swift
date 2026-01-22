//
//  FetchTodayRMSSDUseCaseImpl.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 17/01/26.
//

import Foundation

protocol FetchTodayRMSSDUseCase {
    func execute() async throws -> [HRVPoint]
}

final class FetchTodayRMSSDUseCaseImpl: FetchTodayRMSSDUseCase {

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

        return try await hrvDataSource.fetchTodayRMSSD(
            startDate: start,
            endDate: end
        )
    }
}
