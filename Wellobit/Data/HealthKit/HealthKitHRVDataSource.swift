//
//  HealthKitHRVDataSource.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 17/01/26.
//

import Foundation
import HealthKit

protocol HRVDataSource {
    func fetchTodayHRV(startDate: Date, endDate: Date) async throws -> [HRVPoint]
    func fetchTodayRMSSD(startDate: Date, endDate: Date) async throws -> [HRVPoint]

    func fetchHRVRange(startDate: Date, endDate: Date) async throws -> [HRVPoint]
    func fetchRMSSDRange(startDate: Date, endDate: Date) async throws -> [HRVPoint]
    
    func fetchTodayRHR(startDate: Date, endDate: Date) async throws -> Double?
    func fetchRHRRange(startDate: Date, endDate: Date) async throws -> [Double]

}


final class HealthKitHRVDataSource: HRVDataSource {

    private let healthStore: HKHealthStore

    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }

    // MARK: - SDNN (Native HealthKit)

    func fetchTodayHRV(
        startDate: Date,
        endDate: Date
    ) async throws -> [HRVPoint] {

        let sdnnType = HKQuantityType.quantityType(
            forIdentifier: .heartRateVariabilitySDNN
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sdnnType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let points = (samples as? [HKQuantitySample])?
                    .map { sample in
                        HRVPoint(
                            date: sample.startDate,
                            value: sample.quantity.doubleValue(for: .secondUnit(with: .milli)),
                            type: .sdnn
                        )
                    } ?? []

                continuation.resume(returning: points)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - RMSSD (Custom Calculated)

    func fetchTodayRMSSD(
        startDate: Date,
        endDate: Date
    ) async throws -> [HRVPoint] {

        let heartbeatType = HKSeriesType.heartbeat()

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in

            let query = HKSampleQuery(
                sampleType: heartbeatType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { [weak self] _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let self = self,
                      let seriesSamples = samples as? [HKHeartbeatSeriesSample] else {
                    continuation.resume(returning: [])
                    return
                }

                Task {
                    do {
                        var allPoints: [HRVPoint] = []

                        for series in seriesSamples {
                            let rmssd = try await self.calculateRMSSD(from: series)

                            allPoints.append(
                                HRVPoint(
                                    date: series.startDate,
                                    value: rmssd,
                                    type: .rmssd
                                )
                            )
                        }

                        continuation.resume(returning: allPoints)

                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }

            healthStore.execute(query)
        }
    }

    // MARK: - Helpers
    private func calculateRMSSD(from series: HKHeartbeatSeriesSample) async throws -> Double {

        try await withCheckedThrowingContinuation { continuation in

            var rrIntervals: [Double] = []
            var previousTime: Double?

            let query = HKHeartbeatSeriesQuery(heartbeatSeries: series) { _, timeSinceSeriesStart, precededByGap, done, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                // Process each heartbeat safely
                if precededByGap {
                    previousTime = nil
                } else if let last = previousTime {
                    let rr = timeSinceSeriesStart - last

                    // Accept only realistic RR intervals
                    if rr > 0.3 && rr < 2.0 {
                        rrIntervals.append(rr)
                    }
                }

                previousTime = timeSinceSeriesStart

                // Only finalize when series is finished
                if done {
                    // Always resume – never leave continuation hanging
                    guard rrIntervals.count >= 10 else {
                        continuation.resume(returning: 0)
                        return
                    }

                    let rmssd = self.computeRMSSD(from: rrIntervals)
                    continuation.resume(returning: rmssd)
                }
            }

            healthStore.execute(query)
        }
    }


    private func computeRMSSD(from intervals: [Double]) -> Double {
        guard intervals.count > 1 else { return 0 }

        let successiveDiffs = zip(intervals, intervals.dropFirst()).map { $1 - $0 }

        let squaredDiffs = successiveDiffs.map { $0 * $0 }

        let meanSquare = squaredDiffs.reduce(0, +) / Double(squaredDiffs.count)
        print(sqrt(meanSquare))
        return sqrt(meanSquare)*1000
    }
    
    func fetchHRVRange(startDate: Date, endDate: Date) async throws -> [HRVPoint] {
        let sdnnType = HKQuantityType.quantityType(
            forIdentifier: .heartRateVariabilitySDNN
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sdnnType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let points = (samples as? [HKQuantitySample])?
                    .map {
                        HRVPoint(
                            date: $0.startDate,
                            value: $0.quantity.doubleValue(for: .secondUnit(with: .milli)),
                            type: .sdnn
                        )
                    } ?? []

                continuation.resume(returning: points)
            }

            healthStore.execute(query)
        }
    }

    func fetchRMSSDRange(startDate: Date, endDate: Date) async throws -> [HRVPoint] {

        let heartbeatType = HKSeriesType.heartbeat()

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in

            let query = HKSampleQuery(
                sampleType: heartbeatType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { [weak self] _, samples, error in

                guard let self = self else {
                    continuation.resume(returning: [])
                    return
                }

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let seriesSamples = samples as? [HKHeartbeatSeriesSample] else {
                    continuation.resume(returning: [])
                    return
                }

                Task {
                    var results: [HRVPoint] = []

                    for series in seriesSamples {
                        let rmssd = try await self.calculateRMSSD(from: series)

                        results.append(
                            HRVPoint(
                                date: series.startDate,
                                value: rmssd,
                                type: .rmssd
                            )
                        )
                    }

                    continuation.resume(returning: results)
                }
            }

            healthStore.execute(query)
        }
    }


    
    func fetchTodayRHR(startDate: Date, endDate: Date) async throws -> Double? {

        let rhrType = HKQuantityType.quantityType(
            forIdentifier: .restingHeartRate
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate - 1,
            end: endDate - 1,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in

            let query = HKSampleQuery(
                sampleType: rhrType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let values = (samples as? [HKQuantitySample])?
                    .map {
                        $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    } ?? []

                guard !values.isEmpty else {
                    continuation.resume(returning: nil)
                    return
                }

                // Use average of all RHR samples today
                let avg = values.reduce(0, +) / Double(values.count)

                continuation.resume(returning: avg)
            }

            healthStore.execute(query)
        }
    }
    func fetchRHRRange(startDate: Date, endDate: Date) async throws -> [Double] {

        let rhrType = HKQuantityType.quantityType(
            forIdentifier: .restingHeartRate
        )!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in

            let query = HKSampleQuery(
                sampleType: rhrType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let values = (samples as? [HKQuantitySample])?
                    .map {
                        $0.quantity.doubleValue(
                            for: HKUnit.count().unitDivided(by: .minute())
                        )
                    } ?? []

                continuation.resume(returning: values)
            }

            healthStore.execute(query)
        }
    }

}
