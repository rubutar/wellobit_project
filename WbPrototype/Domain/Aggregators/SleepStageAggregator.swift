//
//  SleepStageAggregator.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


import Foundation
import HealthKit

struct SleepStageAggregator {

    static func aggregate(
        from samples: [HKCategorySample]
    ) -> [SleepStage] {

        var durations: [SleepStageType: TimeInterval] = [:]

        samples.forEach { sample in
            let duration = sample.endDate.timeIntervalSince(sample.startDate)

            guard let stageType = map(sample.value) else {
                return
            }

            durations[stageType, default: 0] += duration
        }

        return durations.map {
            SleepStage(type: $0.key, duration: $0.value)
        }
    }

    private static func map(_ value: Int) -> SleepStageType? {
        switch value {
        case HKCategoryValueSleepAnalysis.awake.rawValue:
            return .awake
        case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
            return .rem
        case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
            return .core
        case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
            return .deep
        default:
            return nil
        }
    }
}
