//
//  SleepScoreCalculating.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//

import Foundation

protocol SleepScoreCalculating {
    func calculate(input: SleepScoreInput) -> SleepScore
}

final class SleepScoreCalculator: SleepScoreCalculating {

    func calculate(input: SleepScoreInput) -> SleepScore {

        let durationScore = durationComponent(hours: input.sleepDurationHours)
        let hrvScore = hrvComponent(
            sleepHRV: input.sleepHRV,
            baselineHRV: input.baselineHRV
        )
        let hrScore = heartRateComponent(
            sleepHR: input.sleepHeartRate,
            baselineHR: input.baselineHeartRate
        )
        let consistencyScore = consistencyComponent(
            bedtime: input.bedtime,
            averageBedtime: input.averageBedtime
        )

        let total = durationScore + hrvScore + hrScore + consistencyScore
        let finalScore = min(max(Int(round(total)), 0), 100)

        return SleepScore(
            value: finalScore,
            label: label(for: finalScore)
        )
    }
}

private extension SleepScoreCalculator {

    func durationComponent(hours: Double) -> Double {
        let ideal = 8.0
        let diff = abs(hours - ideal)
        let score = max(0, 1 - diff / 4)
        return score * 40
    }
}

private extension SleepScoreCalculator {

    func hrvComponent(
        sleepHRV: Double?,
        baselineHRV: Double?
    ) -> Double {

        guard
            let sleepHRV,
            let baselineHRV,
            baselineHRV > 0
        else {
            return 15 // neutral
        }

        let ratio = sleepHRV / baselineHRV

        switch ratio {
        case 1.1...: return 30
        case 1.0..<1.1: return 25
        case 0.9..<1.0: return 20
        case 0.8..<0.9: return 10
        default: return 0
        }
    }
}

private extension SleepScoreCalculator {

    func heartRateComponent(
        sleepHR: Double?,
        baselineHR: Double?
    ) -> Double {

        guard
            let sleepHR,
            let baselineHR
        else {
            return 10 // neutral
        }

        let diff = sleepHR - baselineHR

        switch diff {
        case ...(-5): return 20
        case -4...0: return 15
        case 1...5: return 10
        default: return 0
        }
    }
}

private extension SleepScoreCalculator {

    func consistencyComponent(
        bedtime: Date,
        averageBedtime: Date?
    ) -> Double {

        guard let averageBedtime else {
            return 5 // neutral
        }

        let diffMinutes = abs(bedtime.timeIntervalSince(averageBedtime)) / 60

        switch diffMinutes {
        case 0...30: return 10
        case 31...60: return 7
        case 61...90: return 4
        default: return 0
        }
    }
}

private extension SleepScoreCalculator {

    func label(for score: Int) -> SleepScoreLabel {
        switch score {
        case 85...100: return .excellent
        case 70..<85: return .good
        case 50..<70: return .fair
        default: return .poor
        }
    }
}

