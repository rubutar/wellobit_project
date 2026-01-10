//
//  FetchSleepStages.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


final class FetchSleepStages: FetchSleepStagesUseCase {

    private let repository: HealthKitSleepRepository

    init(repository: HealthKitSleepRepository) {
        self.repository = repository
    }

    func execute() async throws -> [SleepStage] {
        let samples = try await repository.fetchRawSleepStageSamples()
        return SleepStageAggregator.aggregate(from: samples)
    }
}
