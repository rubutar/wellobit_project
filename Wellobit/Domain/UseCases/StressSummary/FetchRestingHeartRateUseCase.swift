//
//  FetchRestingHeartRateUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 12/01/26.
//

import Foundation
import HealthKit

final class FetchRestingHeartRateUseCase {

    private let healthStore = HKHealthStore()

    func execute(
        startDate: Date,
        endDate: Date,
        completion: @escaping ([HKQuantitySample]) -> Void
    ) {
        let type = HKQuantityType.quantityType(
            forIdentifier: .heartRate
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let sort = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: true
        )

        let query = HKSampleQuery(
            sampleType: type,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sort]
        ) { _, samples, _ in
            completion(samples as? [HKQuantitySample] ?? [])
            print("🫀 Raw RHR samples:", samples?.count ?? 0)
        }

        healthStore.execute(query)
    }
}
