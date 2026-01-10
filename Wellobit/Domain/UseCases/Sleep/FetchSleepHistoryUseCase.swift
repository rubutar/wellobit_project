//
//  FetchSleepHistoryUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


protocol FetchSleepHistoryUseCase {
    func execute(range: SleepHistoryRange) async throws -> [DailySleepSummary]
}
