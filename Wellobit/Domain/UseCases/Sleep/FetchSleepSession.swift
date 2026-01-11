//
//  FetchLatestSleepSession.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


final class FetchLatestSleepSession: FetchLatestSleepSessionUseCase {

    private let repository: SleepRepository

    init(repository: SleepRepository) {
        self.repository = repository
    }

    func execute() async throws -> SleepSession? {
        try await repository.fetchLatestSleepSession()
    }
}
