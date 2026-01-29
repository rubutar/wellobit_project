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
        
        let durationScore = durationComponent(
            hours: input.sleepDurationHours
        )
        
        let consistencyScore = consistencyComponent(
            bedtime: input.bedtime,
            averageBedtime: input.averageBedtime
        )
        
        let interruptionScore = interruptionComponent(
            count: input.interruptionCount,
            minutes: input.interruptionMinutes,
            durationHours: input.sleepDurationHours
        )
        
        let total = durationScore + consistencyScore + interruptionScore
        let finalScore = min(max(Int(round(total)), 0), 100)
        
        print("""
        🛌 SleepScore Debug
        Duration: \(String(format: "%.2f", input.sleepDurationHours))h → \(durationScore)/50
        Consistency: \(consistencyScore)/30, \(input.bedtime). \(input.averageBedtime)
        Interruptions: \(interruptionScore)/20, count: \(input.interruptionCount), minutes: \(input.interruptionMinutes)
        --------------------------------
        TOTAL: \(finalScore)
        """)
        
        return SleepScore(
            value: finalScore,
            label: label(for: finalScore)
        )
    }
}

private extension SleepScoreCalculator {

    func durationComponent(hours: Double) -> Double {
        // Apple-like linear scoring centered at 8h
        let clamped = max(4.0, min(hours, 9.0))

        // 8h → 50
        // Each 30 min away ≈ −3 points
        let diff = abs(clamped - 8.0)
        let penalty = (diff / 0.5) * 3

        return max(0, 50 - penalty)
    }

    func consistencyComponent(
        bedtime: Date,
        averageBedtime: Date?
    ) -> Double {

        guard let averageBedtime else { return 15 }

        let cal = Calendar.current

        let bedtimeMinutes =
            cal.component(.hour, from: bedtime) * 60 +
            cal.component(.minute, from: bedtime)

        let averageMinutes =
            cal.component(.hour, from: averageBedtime) * 60 +
            cal.component(.minute, from: averageBedtime)

        // Directional diff (circular clock)
        let rawDiff = bedtimeMinutes - averageMinutes
        let diff = rawDiff >= 0
            ? rawDiff
            : rawDiff + 1440   // handle midnight wrap

        // diff is now "minutes later than average"
        if diff == 0 {
            return 30
        }

        // EARLY bedtime → no penalty
        if diff > 720 {
            return 30
        }

        // LATE bedtime penalties
        switch diff {
        case 1...30:   return 28
        case 31...60:  return 22
        case 61...90:  return 20
        case 91...120: return 14
        case 121...150:return 13
        case 151...180:return 9
        default:       return 0
        }
    }



    func interruptionComponent(
        count: Int,
        minutes: Double,
        durationHours: Double
    ) -> Double {

        // 1️⃣ Base score from awake minutes (dominant)
        let baseScore: Double
        switch minutes {
        case 0...15:   baseScore = 20
        case 16...30:  baseScore = 15
        case 31...45:  baseScore = 13
        case 46...60:  baseScore = 10
        case 61...75:  baseScore = 7
        case 76...90:  baseScore = 5
        default:       baseScore = 3
        }

        var score = baseScore

        // 2️⃣ Soft wake-up penalty (Apple-style)
        if count >= 8 {
            score -= 4
        } else if count >= 6 {
            score -= 2
        }

        // 3️⃣ Never let wakeups overpower minutes
        score = max(score, baseScore - 4)

        return max(0, floor(score))
    }


//
//    
//    func durationPenalty(hours: Double) -> Double {
//        let ideal = 8.0
//        let diff = abs(hours - ideal)
//
//        switch diff {
//        case 0...0.5: return 0
//        case 0.5...1.0: return 5
//        case 1.0...1.5: return 10
//        case 1.5...2.0: return 15
//        case 2.0...2.5: return 20
//        case 2.5...3.0: return 25
//        case 3.0...3.5: return 30
//        case 3.5...4.0: return 35
//        default: return 40
//        }
//    }
//    
//    func interruptionPenalty(
//        count: Int,
//        minutes: Double
//    ) -> Double {
//
//        let minutePenalty: Double
//        switch minutes {
//        case 0...15: minutePenalty = 0
//        case 16...30: minutePenalty = 4
//        case 31...45: minutePenalty = 7
//        case 46...60: minutePenalty = 10
//        case 61...90: minutePenalty = 14
//        default: minutePenalty = 18
//        }
//
//        let countPenalty = min(Double(count), 8) * 0.5
//        print("interruptionComp = \(min(minutePenalty + countPenalty, 20))")
//
//        return min(minutePenalty + countPenalty, 20)
//    }
//
//    
//    func consistencyPenalty(
//        bedtime: Date,
//        averageBedtime: Date?
//    ) -> Double {
//
//        guard let averageBedtime else {
//            return 15
//        }
//
//        let diffMinutes = abs(
//            bedtime.timeIntervalSince(averageBedtime)
//        ) / 60
//
//        switch diffMinutes {
//        case 0...30: return 0
//        case 31...60: return 5
//        case 61...90: return 10
//        case 91...120: return 17
//        case 121...180: return 21
//        default: return 27
//        }
//    }

    struct SleepScoreBreakdown {
        let durationPenalty: Double
        let consistencyPenalty: Double
        let interruptionPenalty: Double

        var totalPenalty: Double {
            durationPenalty + consistencyPenalty + interruptionPenalty
        }

        var finalScore: Int {
            max(0, min(100, Int(round(100 - totalPenalty))))
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
