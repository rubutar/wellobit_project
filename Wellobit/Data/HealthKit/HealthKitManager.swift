//
//  HealthKitManager.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import HealthKit

final class HealthKitManager {

    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    private init() {}

    // MARK: - Authorization

    func requestAuthorization(completion: @escaping (Bool) -> Void) {

        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let readTypes: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKSeriesType.heartbeat()
        ]

        healthStore.requestAuthorization(
            toShare: [],
            read: readTypes
        ) { success, _ in
            completion(success)
        }
    }


    
//    func requestAuthorization(completion: @escaping (Bool) -> Void) {
//        guard HKHealthStore.isHealthDataAvailable(),
//              let hrvType = HKObjectType.quantityType(
//                forIdentifier: .heartRateVariabilitySDNN
//              ) else {
//            completion(false)
//            return
//        }
//
//        healthStore.requestAuthorization(
//            toShare: [],
//            read: [hrvType]
//        ) { success, _ in
//            completion(success)
//        }
//    }

    // MARK: - HRV Fetch

    func fetchHRV(
        startDate: Date,
        endDate: Date,
        completion: @escaping ([HKQuantitySample]) -> Void
    ) {
        guard let hrvType = HKObjectType.quantityType(
            forIdentifier: .heartRateVariabilitySDNN
        ) else {
            completion([])
            return
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: []
        )

        let sort = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: true
        )

        let query = HKSampleQuery(
            sampleType: hrvType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sort]
        ) { _, samples, error in

            guard let samples = samples as? [HKQuantitySample],
                  error == nil else {
                completion([])
                return
            }

            completion(samples)
        }
        healthStore.execute(query)
    }
}
