//
//  MockSleepScoreInputBuilder.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 27/01/26.
//


//
//  MockSleepScoreInputBuilder.swift
//  Wellobit
//

import Foundation

struct MockSleepScoreInputBuilder: SleepScoreInputBuilding {

    func build(for date: Date) async throws -> SleepScoreInput? {

        let calendar = Calendar.current

        let bedtime = calendar.date(
            bySettingHour: 23,
            minute: 15,
            second: 0,
            of: date
        )!

        let averageBedtime = calendar.date(
            bySettingHour: 23,
            minute: 30,
            second: 0,
            of: date
        )

        return SleepScoreInput(
            sleepDurationHours: 7.5,     // 7h 30m
            bedtime: bedtime,
            averageBedtime: averageBedtime,
            interruptionCount: 2,        // woke up twice
            interruptionMinutes: 10      // total 10 minutes awake
        )
    }
}



extension SleepScoreViewModel {

    static func mock() -> SleepScoreViewModel {
        let vm = SleepScoreViewModel(
            inputBuilder: MockSleepScoreInputBuilder()
        )

        Task {
            await vm.loadSleepScore(for: Date())
        }

        return vm
    }
}
