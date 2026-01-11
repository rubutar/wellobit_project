//
//  FetchSleepHistory.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//

protocol FetchSleepHistoryUseCase {
    func execute(range: SleepHistoryRange) async throws -> [DailySleepSummary]
}


final class FetchSleepHistory: FetchSleepHistoryUseCase {

    private let repository: HealthKitSleepRepository

    init(repository: HealthKitSleepRepository) {
        self.repository = repository
    }

    func execute(
        range: SleepHistoryRange
    ) async throws -> [DailySleepSummary] {

        let samples = try await repository.fetchSleepSamples(
            days: range.days
        )

        return SleepHistoryAggregator.aggregate(
            samples: samples
        )
    }
}
