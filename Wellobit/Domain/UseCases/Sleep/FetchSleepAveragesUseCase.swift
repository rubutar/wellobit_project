//
//  FetchSleepAveragesUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


protocol FetchSleepAveragesUseCase {
    func execute(
        range: SleepHistoryRange,
        history: [DailySleepSummary]
    ) async throws -> SleepAverages
}
