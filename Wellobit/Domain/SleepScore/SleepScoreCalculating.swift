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
