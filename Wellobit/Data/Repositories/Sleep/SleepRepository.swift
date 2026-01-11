//
//  SleepRepository.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//

import Foundation

protocol SleepRepository {

    func fetchSleepSession(for date: Date) async throws -> SleepSession?

    func fetchSleepStages(for date: Date) async throws -> [SleepStage]

    func fetchSleepHistory(
        range: SleepHistoryRange
    ) async throws -> [DailySleepSummary]

    func fetchAverageBedtime(days: Int) async throws -> Date?
}
