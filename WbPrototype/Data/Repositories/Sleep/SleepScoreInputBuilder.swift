//
//  SleepScoreInputBuilder.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import Foundation

protocol SleepScoreInputBuilding {
    func build(for date: Date) async throws -> SleepScoreInput?
}

final class SleepScoreInputBuilder: SleepScoreInputBuilding {

    private let sleepRepository: SleepRepository
    private let vitalsRepository: VitalsRepository

    init(
        sleepRepository: SleepRepository,
        vitalsRepository: VitalsRepository
    ) {
        self.sleepRepository = sleepRepository
        self.vitalsRepository = vitalsRepository
    }

    func build(for date: Date) async throws -> SleepScoreInput? {
        guard let session = try await sleepRepository.fetchSleepSession(for: date)
        else {
            return nil
        }

        async let sleepHR = vitalsRepository.fetchSleepHR(
            start: session.startDate,
            end: session.endDate
        )

        async let sleepHRV = vitalsRepository.fetchSleepHRV(
            start: session.startDate,
            end: session.endDate
        )

        async let baselineHR = vitalsRepository.fetchBaselineHR(days: 7)
        async let baselineHRV = vitalsRepository.fetchBaselineHRV(days: 7)

        let averageBedtime = try await sleepRepository.fetchAverageBedtime(days: 7)

//        return SleepScoreInput(
//            sleepDurationHours: session.duration / 3600,
//            bedtime: session.startDate,
//            sleepHRV: try await sleepHRV,
//            baselineHRV: try await baselineHRV,
//            sleepHeartRate: try await sleepHR,
//            baselineHeartRate: try await baselineHR,
//            averageBedtime: averageBedtime
//        )
        let awakeStages = session.stages
            .filter { $0.type == .awake && $0.duration >= 90 }

        let interruptionMinutes = awakeStages
            .map { $0.duration / 60 }
            .reduce(0, +)

        let interruptionCount = awakeStages.count
        let asleepDurationSeconds = session.stages
            .filter { $0.type != .awake }
            .map(\.duration)
            .reduce(0, +)

        let sleepDurationHours = asleepDurationSeconds / 3600

        
        return SleepScoreInput(
            sleepDurationHours: sleepDurationHours,
            bedtime: session.startDate,
            averageBedtime: averageBedtime,
            interruptionCount: interruptionCount,
            interruptionMinutes: interruptionMinutes
        )

    }
}
