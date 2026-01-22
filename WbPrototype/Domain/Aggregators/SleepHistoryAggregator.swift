//
//  SleepHistoryAggregator.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


import Foundation
import HealthKit

struct SleepHistoryAggregator {

    static func aggregate(
        samples: [HKCategorySample]
    ) -> [DailySleepSummary] {

        let calendar = Calendar.current

        let asleepValues: Set<Int> = [
            HKCategoryValueSleepAnalysis.asleep.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue
        ]

        var dailyDurations: [Date: TimeInterval] = [:]

        samples
            .filter { asleepValues.contains($0.value) }
            .forEach { sample in
                let day = calendar.startOfDay(for: sample.endDate)
                let duration = sample.endDate.timeIntervalSince(sample.startDate)
                dailyDurations[day, default: 0] += duration
            }

        return dailyDurations
            .map {
                DailySleepSummary(
                    date: $0.key,
                    sleepDuration: $0.value
                )
            }
            .sorted { $0.date < $1.date }
    }
}
