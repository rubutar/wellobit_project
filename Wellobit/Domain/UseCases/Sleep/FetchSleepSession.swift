//
//  FetchSleepSessionUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import Foundation

protocol FetchSleepSessionUseCase {
    func execute(for date: Date) async throws -> SleepSession?
}

final class FetchSleepSession: FetchSleepSessionUseCase {

    private let repository: SleepRepository

    init(repository: SleepRepository) {
        self.repository = repository
    }

    func execute(for date: Date) async throws -> SleepSession? {
        try await repository.fetchSleepSession(for: date)
    }
}
