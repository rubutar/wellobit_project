//
//  HealthKitHeartRateDataSource.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 18/01/26.
//


import HealthKit

import Foundation

protocol HeartRateDataSource {
    func fetchHeartRateSamples(
        startDate: Date,
        endDate: Date
    ) async throws -> [HeartRateSample]
}


final class HealthKitHeartRateDataSource: HeartRateDataSource {

    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    func fetchHeartRateSamples(
        startDate: Date,
        endDate: Date
    ) async throws -> [HeartRateSample] {

        let heartRateType = HKQuantityType.quantityType(
            forIdentifier: .heartRate
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate
        )

        return try await withCheckedThrowingContinuation { continuation in

            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [
                    NSSortDescriptor(
                        key: HKSampleSortIdentifierStartDate,
                        ascending: true
                    )
                ]
            ) { _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let hrSamples = (samples as? [HKQuantitySample])?
                    .map {
                        HeartRateSample(
                            date: $0.startDate,
                            bpm: $0.quantity.doubleValue(
                                for: HKUnit.count()
                                    .unitDivided(by: .minute())
                            )
                        )
                    } ?? []

                continuation.resume(returning: hrSamples)
            }

            self.healthStore.execute(query)
        }
    }
}
