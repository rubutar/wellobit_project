//
//  SleepRepository.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//

protocol SleepRepository {
    func fetchLatestSleepSession() async throws -> SleepSession?
}
