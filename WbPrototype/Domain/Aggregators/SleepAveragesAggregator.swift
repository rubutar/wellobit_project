//
//  SleepAveragesAggregator.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


import Foundation
import HealthKit

struct SleepAveragesAggregator {

    static func average(
        sleepHistory: [DailySleepSummary],
        heartRate: [HKQuantitySample],
        hrv: [HKQuantitySample],
        respiratoryRate: [HKQuantitySample]
    ) -> SleepAverages {

        let avgSleep = sleepHistory.map(\.sleepDuration).average()

        let avgHR = heartRate
            .map { $0.quantity.doubleValue(for: .count().unitDivided(by: .minute())) }
            .average()

        let avgHRV = hrv
            .map { $0.quantity.doubleValue(for: .secondUnit(with: .milli)) }
            .average()

        let avgResp = respiratoryRate
            .map { $0.quantity.doubleValue(for: .count().unitDivided(by: .minute())) }
            .average()

        return SleepAverages(
            averageSleepDuration: avgSleep ?? 0,
            averageHeartRate: avgHR,
            averageHRV: avgHRV,
            averageRespiratoryRate: avgResp
        )
    }
}

extension Array where Element == Double {
    func average() -> Double? {
        guard !isEmpty else { return nil }
        return reduce(0, +) / Double(count)
    }
}
