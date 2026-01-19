//
//  FetchTodayHeartRateSamplesUseCaseImpl.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 18/01/26.
//



import Foundation

protocol FetchTodayHeartRateSamplesUseCase {
    func execute(
        startDate: Date,
        endDate: Date
    ) async throws -> [HeartRateSample]
}


final class FetchTodayHeartRateSamplesUseCaseImpl: FetchTodayHeartRateSamplesUseCase {

    private let dataSource: HeartRateDataSource

    init(dataSource: HeartRateDataSource) {
        self.dataSource = dataSource
    }

    func execute(
        startDate: Date,
        endDate: Date
    ) async throws -> [HeartRateSample] {
        try await dataSource.fetchHeartRateSamples(
            startDate: startDate,
            endDate: endDate
        )
    }
}
