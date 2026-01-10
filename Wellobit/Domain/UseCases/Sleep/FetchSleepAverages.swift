//
//  FetchSleepAverages.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


final class FetchSleepAverages: FetchSleepAveragesUseCase {

    private let repository: HealthKitSleepRepository

    init(repository: HealthKitSleepRepository) {
        self.repository = repository
    }

    func execute(
        range: SleepHistoryRange,
        history: [DailySleepSummary]
    ) async throws -> SleepAverages {

        let days = range.days

        async let heartRateSamples =
            repository.fetchHeartRateSamples(days: days)

        async let hrvSamples =
            repository.fetchHRVSamples(days: days)

        async let respiratorySamples =
            repository.fetchRespiratoryRateSamples(days: days)

        let averages = SleepAveragesAggregator.average(
            sleepHistory: history,
            heartRate: try await heartRateSamples,
            hrv: try await hrvSamples,
            respiratoryRate: try await respiratorySamples
        )

        return averages
    }
}
