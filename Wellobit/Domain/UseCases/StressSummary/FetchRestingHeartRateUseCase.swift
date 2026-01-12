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
        }

        healthStore.execute(query)
    }
    
    func execute(
        for date: Date,
        completion: @escaping ([(Date, Double)]) -> Void
    ) {
        let endDate = Calendar.current.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: date
        ) ?? date

        let startDate = Calendar.current.date(
            byAdding: .hour,
            value: -24,
            to: endDate
        )!

        execute(startDate: startDate, endDate: endDate) { samples in
            let mapped = samples.map {
                (
                    $0.startDate,
                    $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                )
            }

            print("❤️ HR mapped samples:", mapped.count)
            completion(mapped)
        }
    }

}
