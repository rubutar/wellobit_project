//
//  EmptySleepSessionUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 19/01/26.
//

import Foundation

struct EmptyFetchSleepSessionUseCase: FetchSleepSessionUseCase {
    func execute(for date: Date) async throws -> SleepSession? {
        nil
    }
}

struct EmptyFetchSleepUseCase: FetchSleepSessionUseCase {
    func execute(for date: Date) async throws -> SleepSession? {
        nil
    }
}

struct EmptyFetchSleepStagesUseCase: FetchSleepStagesUseCase {
    func execute(for date: Date) async throws -> [SleepStage] {
        []
    }
}

struct EmptyFetchSleepHistoryUseCase: FetchSleepHistoryUseCase {
    func execute(range: SleepHistoryRange) async throws -> [DailySleepSummary] {
        []
    }
}

extension SleepAverages {
    static let empty = SleepAverages(
        averageSleepDuration: 0,
        averageHeartRate: 0,
        averageHRV: 0,
        averageRespiratoryRate: 0
    )
}

struct EmptyFetchSleepAveragesUseCase: FetchSleepAveragesUseCase {
    func execute(range: SleepHistoryRange, history: [DailySleepSummary]) async throws -> SleepAverages {
        .empty
    }
}
