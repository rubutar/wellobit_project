//
//  FetchSleepLast24HoursUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import Foundation
import HealthKit

//final class FetchSleepLast24HoursUseCase {
//
//    private let healthStore = HKHealthStore()
//
//    func execute(
//        anchorDate: Date,
//        completion: @escaping ([SleepSession]) -> Void
//    ) {
//        guard let sleepType = HKObjectType.categoryType(
//            forIdentifier: .sleepAnalysis
//        ) else {
//            completion([])
//            return
//        }
//
//        let endDate = anchorDate
//        let startDate = Calendar.current.date(
//            byAdding: .hour,
//            value: -24,
//            to: endDate
//        )!
//
//        let predicate = HKQuery.predicateForSamples(
//            withStart: startDate,
//            end: endDate,
//            options: []
//        )
//
//        let query = HKSampleQuery(
//            sampleType: sleepType,
//            predicate: predicate,
//            limit: HKObjectQueryNoLimit,
//            sortDescriptors: nil
//        ) { _, samples, _ in
//
//            guard let samples = samples as? [HKCategorySample] else {
//                completion([])
//                return
//            }
//
//            let sessions: [SleepSession] = samples
//                .filter { $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue }
//                .map {
//                    SleepSession(
//                        startDate: $0.startDate,
//                        endDate: $0.endDate,
//                        duration: $0.endDate.timeIntervalSince($0.startDate)
//                    )
//                }
//
//            completion(sessions)
//        }
//
//        healthStore.execute(query)
//    }
//}


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

            guard let samples = samples as? [HKCategorySample],
                  !samples.isEmpty else {
                completion([])
                return
            }

            // 1️⃣ Map samples → stages
            let stages: [SleepStage] = samples.compactMap { sample in
                guard let type = SleepStageType(from: sample.value) else {
                    return nil
                }

                return SleepStage(
                    type: type,
                    duration: sample.endDate.timeIntervalSince(sample.startDate)
                )
            }

            // 2️⃣ Build session bounds
            let sessionStart = samples.map(\.startDate).min()!
            let sessionEnd = samples.map(\.endDate).max()!
            let duration = sessionEnd.timeIntervalSince(sessionStart)

            // 3️⃣ Build SleepSession
            let session = SleepSession(
                startDate: sessionStart,
                endDate: sessionEnd,
                duration: duration,
                stages: stages
            )

            completion([session])
        }

        healthStore.execute(query)
    }
}
