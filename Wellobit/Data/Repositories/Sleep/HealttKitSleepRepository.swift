//
//  HealttKitSleepRepository.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//

import HealthKit

final class HealthKitSleepRepository: SleepRepository {

    private let healthStore = HKHealthStore()

    func fetchLatestSleepSession() async throws -> SleepSession? {

        let sleepType = HKObjectType.categoryType(
            forIdentifier: .sleepAnalysis
        )!

        let calendar = Calendar.current

        let startOfYesterdayAtNoon = calendar.date(
            bySettingHour: 12,
            minute: 0,
            second: 0,
            of: calendar.date(byAdding: .day, value: -1, to: Date())!
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfYesterdayAtNoon,
            end: Date(),
            options: []
        )

        return try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<SleepSession?, Error>) in

            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }

                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue
                ]

                let asleepSamples = samples
                    .filter { asleepValues.contains($0.value) }
                    .sorted { $0.startDate < $1.startDate }

                guard let first = asleepSamples.first,
                      let last = asleepSamples.last else {
                    continuation.resume(returning: nil)
                    return
                }

                let session = SleepSession(
                    startDate: first.startDate,
                    endDate: last.endDate,
                    duration: last.endDate.timeIntervalSince(first.startDate)
                )

                continuation.resume(returning: session)
            }

            healthStore.execute(query)
        }
    }
    
    func fetchRawSleepStageSamples() async throws -> [HKCategorySample] {

        let sleepType = HKObjectType.categoryType(
            forIdentifier: .sleepAnalysis
        )!

        let calendar = Calendar.current

        let startOfYesterdayAtNoon = calendar.date(
            bySettingHour: 12,
            minute: 0,
            second: 0,
            of: calendar.date(byAdding: .day, value: -1, to: Date())!
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfYesterdayAtNoon,
            end: Date(),
            options: []
        )

        return try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<[HKCategorySample], Error>) in

            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [
                    NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
                ]
            ) { _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let stageSamples = (samples as? [HKCategorySample]) ?? []


                continuation.resume(returning: stageSamples)
            }

            healthStore.execute(query)
        }
    }
    
    func fetchSleepSamples(
        days: Int
    ) async throws -> [HKCategorySample] {

        let sleepType = HKObjectType.categoryType(
            forIdentifier: .sleepAnalysis
        )!

        let calendar = Calendar.current
        let startDate = calendar.date(
            byAdding: .day,
            value: -days,
            to: Date()
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: Date(),
            options: []
        )

        return try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<[HKCategorySample], Error>) in

            let query = HKSampleQuery(
                sampleType: sleepType,
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

                let sleepSamples = (samples as? [HKCategorySample]) ?? []
                continuation.resume(returning: sleepSamples)
            }

            healthStore.execute(query)
        }
    }
    
    func fetchHeartRateSamples(
        days: Int
    ) async throws -> [HKQuantitySample] {

        let type = HKObjectType.quantityType(
            forIdentifier: .heartRate
        )!

        let startDate = Calendar.current.date(
            byAdding: .day,
            value: -days,
            to: Date()
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: Date(),
            options: []
        )

        return try await fetchQuantitySamples(
            type: type,
            predicate: predicate
        )
    }
    
    func fetchHRVSamples(
        days: Int
    ) async throws -> [HKQuantitySample] {

        let type = HKObjectType.quantityType(
            forIdentifier: .heartRateVariabilitySDNN
        )!

        let startDate = Calendar.current.date(
            byAdding: .day,
            value: -days,
            to: Date()
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: Date(),
            options: []
        )

        return try await fetchQuantitySamples(
            type: type,
            predicate: predicate
        )
    }
    
    func fetchRespiratoryRateSamples(
        days: Int
    ) async throws -> [HKQuantitySample] {

        let type = HKObjectType.quantityType(
            forIdentifier: .respiratoryRate
        )!

        let startDate = Calendar.current.date(
            byAdding: .day,
            value: -days,
            to: Date()
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: Date(),
            options: []
        )

        return try await fetchQuantitySamples(
            type: type,
            predicate: predicate
        )
    }
    private func fetchQuantitySamples(
        type: HKQuantityType,
        predicate: NSPredicate
    ) async throws -> [HKQuantitySample] {

        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<[HKQuantitySample], Error>) in

            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let results = (samples as? [HKQuantitySample]) ?? []
                continuation.resume(returning: results)
            }

            healthStore.execute(query)
        }
    }
}
