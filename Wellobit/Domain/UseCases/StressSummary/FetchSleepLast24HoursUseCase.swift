//
//  FetchSleepLast24HoursUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import Foundation
import HealthKit

final class FetchSleepLast24HoursUseCase {

    private let healthStore = HKHealthStore()

    func execute(
        anchorDate: Date,
        completion: @escaping ([SleepSession]) -> Void
    ) {
        guard let sleepType = HKObjectType.categoryType(
            forIdentifier: .sleepAnalysis
        ) else {
            completion([])
            return
        }

        let endDate = anchorDate
        let startDate = Calendar.current.date(
            byAdding: .hour,
            value: -24,
            to: endDate
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: []
        )

        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, _ in

            guard let samples = samples as? [HKCategorySample] else {
                completion([])
                return
            }

            let sessions: [SleepSession] = samples
                .filter { $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue }
                .map {
                    SleepSession(
                        startDate: $0.startDate,
                        endDate: $0.endDate,
                        duration: $0.endDate.timeIntervalSince($0.startDate)
                    )
                }

            completion(sessions)
        }

        healthStore.execute(query)
    }
}
