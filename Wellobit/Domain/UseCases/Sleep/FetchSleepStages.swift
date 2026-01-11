//
//  FetchSleepStages.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//

import Foundation

protocol FetchSleepStagesUseCase {
    func execute(for date: Date) async throws -> [SleepStage]
}


final class FetchSleepStages: FetchSleepStagesUseCase {

    private let repository: SleepRepository

    init(repository: SleepRepository) {
        self.repository = repository
    }

    func execute(for date: Date) async throws -> [SleepStage] {
        let samples = try await repository.fetchSleepStages(for: date)
        return samples
    }
}
