//
//  FetchHRBaselineUseCaseImpl.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 29/01/26.
//

import Foundation

protocol FetchHRBaselineUseCase {
    func execute(days: Int) async throws -> Double?
}


final class FetchHRBaselineUseCaseImpl: FetchHRBaselineUseCase {

    private let dataSource: HeartRateDataSource
    private let calendar: Calendar

    init(
        dataSource: HeartRateDataSource,
        calendar: Calendar = .current
    ) {
        self.dataSource = dataSource
        self.calendar = calendar
    }

    func execute(days: Int = 7) async throws -> Double? {

        let end = Date()
        let start = calendar.date(byAdding: .day, value: -days, to: end)!

        return try await dataSource.fetchAverageHeartRate(
            startDate: start,
            endDate: end
        )
    }
}
