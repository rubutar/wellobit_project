//
//  FetchLatestSleepSessionUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//

protocol FetchLatestSleepSessionUseCase {
    func execute() async throws -> SleepSession?
}
