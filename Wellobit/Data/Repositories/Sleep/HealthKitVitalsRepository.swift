//
//  VitalsRepository.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import HealthKit

protocol VitalsRepository {
    func fetchSleepHR(start: Date, end: Date) async throws -> Double?
    func fetchSleepHRV(start: Date, end: Date) async throws -> Double?

    func fetchBaselineHR(days: Int) async throws -> Double?
    func fetchBaselineHRV(days: Int) async throws -> Double?
}

final class HealthKitVitalsRepository: VitalsRepository {

    private let healthStore = HKHealthStore()

    func fetchSleepHR(start: Date, end: Date) async throws -> Double? {
        try await averageQuantity(
            identifier: .heartRate,
            unit: HKUnit.count().unitDivided(by: .minute()),
            start: start,
            end: end
        )
    }

    func fetchSleepHRV(start: Date, end: Date) async throws -> Double? {
        try await averageQuantity(
            identifier: .heartRateVariabilitySDNN,
            unit: HKUnit.secondUnit(with: .milli),
            start: start,
            end: end
        )
    }

    func fetchBaselineHR(days: Int) async throws -> Double? {
        try await averageQuantity(
            identifier: .heartRate,
            unit: HKUnit.count().unitDivided(by: .minute()),
            start: Calendar.current.date(byAdding: .day, value: -days, to: Date())!,
            end: Date()
        )
    }

    func fetchBaselineHRV(days: Int) async throws -> Double? {
        try await averageQuantity(
            identifier: .heartRateVariabilitySDNN,
            unit: HKUnit.secondUnit(with: .milli),
            start: Calendar.current.date(byAdding: .day, value: -days, to: Date())!,
            end: Date()
        )
    }

    // MARK: - Helper

    private func averageQuantity(
        identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        start: Date,
        end: Date
    ) async throws -> Double? {

        let type = HKQuantityType.quantityType(forIdentifier: identifier)!

        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictEndDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let value = result?.averageQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: value)
            }

            healthStore.execute(query)
        }
    }
}
