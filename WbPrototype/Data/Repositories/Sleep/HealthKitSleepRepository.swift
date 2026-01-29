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
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue,
                    HKCategoryValueSleepAnalysis.awake.rawValue
                ]

                let asleepSamples = samples
                    .filter { asleepValues.contains($0.value) }
                    .sorted { $0.startDate < $1.startDate }
                
                let sessionSamples = samples
                    .filter { asleepValues.contains($0.value) }
                    .sorted { $0.startDate < $1.startDate }

                guard let first = asleepSamples.first,
                      let last = asleepSamples.last else {
                    continuation.resume(returning: nil)
                    return
                }

                let stages: [SleepStage] = sessionSamples.compactMap { sample in
                    guard let type = SleepStageType(from: sample.value) else {
                        return nil
                    }

                    return SleepStage(
                        type: type,
                        duration: sample.endDate.timeIntervalSince(sample.startDate)
                    )
                }
                
                let session = SleepSession(
                    startDate: first.startDate,
                    endDate: last.endDate,
                    duration: last.endDate.timeIntervalSince(first.startDate),
                    stages: stages

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

                guard let samples = samples as? [HKCategorySample],
                      !samples.isEmpty else {
                    continuation.resume(returning: nil)
                    return
                }

                // 1️⃣ Build stages (awake included for interruptions)
                let stages: [SleepStage] = samples.compactMap { sample in
                    guard let type = SleepStageType(from: sample.value) else {
                        return nil
                    }

                    return SleepStage(
                        type: type,
                        duration: sample.endDate.timeIntervalSince(sample.startDate)
                    )
                }

                // 2️⃣ Determine session bounds from asleep stages
                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue
                ]

                let asleepStages = samples
                    .filter { asleepValues.contains($0.value) }
                    .sorted { $0.startDate < $1.startDate }

                guard let first = asleepStages.first,
                      let last = asleepStages.last else {
                    continuation.resume(returning: nil)
                    return
                }

                // 3️⃣ Build SleepSession
                let session = SleepSession(
                    startDate: first.startDate,
                    endDate: last.endDate,
                    duration: last.endDate.timeIntervalSince(first.startDate),
                    stages: stages
                )

                continuation.resume(returning: session)
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
    
//    func fetchAverageBedtime(days: Int) async throws -> Date? {
//
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        let startDate = calendar.date(byAdding: .day, value: -days, to: today)!
//
//        let sleepType = HKObjectType.categoryType(
//            forIdentifier: .sleepAnalysis
//        )!
//
//        let predicate = HKQuery.predicateForSamples(
//            withStart: startDate,
//            end: today,
//            options: .strictEndDate
//        )
//
//        return try await withCheckedThrowingContinuation { continuation in
//
//            let query = HKSampleQuery(
//                sampleType: sleepType,
//                predicate: predicate,
//                limit: HKObjectQueryNoLimit,
//                sortDescriptors: nil
//            ) { _, samples, error in
//
//                if let error {
//                    continuation.resume(throwing: error)
//                    return
//                }
//
//                let asleepValues: Set<Int> = [
//                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
//                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
//                    HKCategoryValueSleepAnalysis.asleepREM.rawValue
//                ]
//
//                guard
//                    let samples = samples as? [HKCategorySample]
//                else {
//                    continuation.resume(returning: nil)
//                    return
//                }
//
//                // ✅ One bedtime per night
//                let bedtimes = samples
//                    .filter { asleepValues.contains($0.value) }
//                    .sorted { $0.startDate < $1.startDate }
//                    .reduce(into: [Date: Date]()) { dict, sample in
//                        let night = calendar.startOfDay(for: sample.startDate)
//                        dict[night] = min(dict[night] ?? sample.startDate, sample.startDate)
//                    }
//                    .map { $0.value }
//
//                guard !bedtimes.isEmpty else {
//                    continuation.resume(returning: nil)
//                    return
//                }
//
//                // ✅ Average minutes since midnight
//                let minutes = bedtimes.map {
//                    calendar.component(.hour, from: $0) * 60 +
//                    calendar.component(.minute, from: $0)
//                }
//
//                let avgMinutes = minutes.reduce(0, +) / minutes.count
//
//                let avgDate = calendar.date(
//                    bySettingHour: avgMinutes / 60,
//                    minute: avgMinutes % 60,
//                    second: 0,
//                    of: today
//                )
//
//                continuation.resume(returning: avgDate)
//            }
//
//            healthStore.execute(query)
//        }
//    }


    func fetchAverageBedtime(days: Int = 7) async throws -> Date? {

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

                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }

                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue
                ]

                // 1️⃣ Group samples by night
                let grouped = Dictionary(grouping: samples.filter {
                    asleepValues.contains($0.value)
                }) { sample in
                    calendar.startOfDay(for: sample.startDate)
                }

                // 2️⃣ First sustained sleep per night (≥15 min)
                var bedtimes: [Date] = []

                for (_, nightSamples) in grouped {
                    let sorted = nightSamples.sorted { $0.startDate < $1.startDate }

                    var accumulated: TimeInterval = 0
                    var start: Date?

                    for s in sorted {
                        if start == nil {
                            start = s.startDate
                            accumulated = s.endDate.timeIntervalSince(s.startDate)
                        } else {
                            accumulated += s.endDate.timeIntervalSince(s.startDate)
                        }

                        if accumulated >= 15 * 60 {
                            bedtimes.append(start!)
                            break
                        }
                    }
                }

                guard bedtimes.count >= 3 else {
                    continuation.resume(returning: nil)
                    return
                }

                // 3️⃣ Convert to minutes since midnight
                var minutes = bedtimes.map {
                    calendar.component(.hour, from: $0) * 60 +
                    calendar.component(.minute, from: $0)
                }

                // 4️⃣ Outlier suppression (Apple-like)
                if minutes.count >= 5 {
                    minutes.sort()
                    minutes.removeFirst()
                    minutes.removeLast()
                }

                // 5️⃣ Weight recent nights
                let weights: [Int] = [3, 2, 2, 1, 1, 1, 1]
                let weighted = zip(minutes.reversed(), weights)
                    .map { Double($0.0 * $0.1) }

                let weightSum = zip(minutes.reversed(), weights)
                    .map { Double($0.1) }
                    .reduce(0, +)

                let avgMinutes = Int(weighted.reduce(0, +) / weightSum)

                // 6️⃣ Rebuild Date (time-only)
                let avgDate = calendar.date(
                    byAdding: .minute,
                    value: avgMinutes - 45,
                    to: today
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
