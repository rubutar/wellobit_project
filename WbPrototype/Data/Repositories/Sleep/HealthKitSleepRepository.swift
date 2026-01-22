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
    
    func fetchSleepSession(for date: Date) async throws -> SleepSession? {

        let sleepType = HKObjectType.categoryType(
            forIdentifier: .sleepAnalysis
        )!

        let window = nightWindow(for: date)

        let predicate = HKQuery.predicateForSamples(
            withStart: window.start,
            end: window.end,
            options: .strictEndDate
        )

        return try await withCheckedThrowingContinuation { continuation in
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

                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue
                ]

                let asleep = (samples as? [HKCategorySample])?
                    .filter { asleepValues.contains($0.value) }
                    .sorted { $0.startDate < $1.startDate }

                guard
                    let first = asleep?.first,
                    let last = asleep?.last
                else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(
                    returning: SleepSession(
                        startDate: first.startDate,
                        endDate: last.endDate,
                        duration: last.endDate.timeIntervalSince(first.startDate)
                    )
                )
            }

            healthStore.execute(query)
        }
    }



    func fetchSleepStages(for date: Date) async throws -> [SleepStage] {

        let sleepType = HKObjectType.categoryType(
            forIdentifier: .sleepAnalysis
        )!

        let window = nightWindow(for: date)

        let predicate = HKQuery.predicateForSamples(
            withStart: window.start,
            end: window.end,
            options: .strictEndDate
        )

        return try await withCheckedThrowingContinuation { continuation in

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
                    continuation.resume(returning: [])
                    return
                }

                let grouped = Dictionary(
                    grouping: samples.compactMap { sample -> (SleepStageType, HKCategorySample)? in
                        guard let type = SleepStageType(from: sample.value) else { return nil }
                        return (type, sample)
                    },
                    by: { $0.0 }
                )

                let stages: [SleepStage] = grouped.map { type, items in
                    SleepStage(
                        type: type,
                        duration: items.reduce(0) {
                            $0 + $1.1.endDate.timeIntervalSince($1.1.startDate)
                        }
                    )
                }
                continuation.resume(returning: stages)
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
    
    func fetchAverageBedtime(days: Int) async throws -> Date? {

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -days, to: today)!

        let sleepType = HKObjectType.categoryType(
            forIdentifier: .sleepAnalysis
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: today,
            options: .strictEndDate
        )

        return try await withCheckedThrowingContinuation { continuation in

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

                let bedtimes = (samples as? [HKCategorySample])?
                    .filter {
                        $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue
                    }
                    .map { $0.startDate }

                guard
                    let times = bedtimes,
                    !times.isEmpty
                else {
                    continuation.resume(returning: nil)
                    return
                }

                // ⏰ Average bedtime (minutes from midnight)
                let minutes = times.map {
                    calendar.component(.hour, from: $0) * 60
                    + calendar.component(.minute, from: $0)
                }

                let avgMinutes = minutes.reduce(0, +) / minutes.count

                let avgDate = calendar.date(
                    bySettingHour: avgMinutes / 60,
                    minute: avgMinutes % 60,
                    second: 0,
                    of: today
                )

                continuation.resume(returning: avgDate)
            }

            healthStore.execute(query)
        }
    }

    func fetchSleepHistory(
        range: SleepHistoryRange
    ) async throws -> [DailySleepSummary] {

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = range.days

        let startDate = calendar.date(
            byAdding: .day,
            value: -days + 1,
            to: today
        )!

        let sleepType = HKObjectType.categoryType(
            forIdentifier: .sleepAnalysis
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: today,
            options: .strictEndDate
        )

        let samples: [HKCategorySample] = try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [
                    NSSortDescriptor(
                        key: HKSampleSortIdentifierEndDate,
                        ascending: true
                    )
                ]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(
                    returning: (samples as? [HKCategorySample]) ?? []
                )
            }

            healthStore.execute(query)
        }

        // 1️⃣ Group sleep by wake-up day (endDate)
        let groupedByDay = Dictionary(
            grouping: samples.filter {
                $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue
            },
            by: { calendar.startOfDay(for: $0.endDate) }
        )

        // 2️⃣ Build continuous timeline (missing days = 0)
        return (0..<days).compactMap { offset in
            let day = calendar.date(
                byAdding: .day,
                value: -offset,
                to: today
            )!

            let duration = groupedByDay[day]?
                .reduce(0) {
                    $0 + $1.endDate.timeIntervalSince($1.startDate)
                } ?? 0

            return DailySleepSummary(
                date: day,
                sleepDuration: duration
            )
        }
        .sorted { $0.date < $1.date }
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
    private func nightWindow(for date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        let start = calendar.date(
            byAdding: .hour,
            value: -12,
            to: startOfDay
        )!

        let end = calendar.date(
            byAdding: .hour,
            value: 12,
            to: startOfDay
        )!

        return (start, end)
    }

}
