//
//  HealthKitPermissionManager.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//

import HealthKit

final class HealthKitPermissionManager {

    private let healthStore = HKHealthStore()

    func requestSleepPermission() async throws {

        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
        ]

        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in

            healthStore.requestAuthorization(
                toShare: [],
                read: readTypes
            ) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

