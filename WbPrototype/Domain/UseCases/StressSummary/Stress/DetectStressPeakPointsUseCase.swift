//
//  DetectStressPeakPointsUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 13/01/26.
//


import Foundation

final class DetectStressPeakPointsUseCase {

    private let threshold: Double
    private let minBuckets: Int

    init(
        threshold: Double = 75,
        minBuckets: Int = 2   // 20 min if bucket = 10 min
    ) {
        self.threshold = threshold
        self.minBuckets = minBuckets
    }

    func execute(states: [StressState]) -> [Date] {

        let valid = states
            .filter { $0.source != .sleepRecovery }
            .compactMap { state -> (Date, Double)? in
                guard let value = state.value else { return nil }
                return (state.date, value)
            }

        guard valid.count >= 3 else { return [] }

        var peakDates: [Date] = []

        for i in 1..<(valid.count - 1) {

            let prev = valid[i - 1].1
            let curr = valid[i].1
            let next = valid[i + 1].1

            // Local maximum + high enough
            guard curr >= threshold, curr > prev, curr >= next else { continue }

            // Sustained check
            let sustained = valid[i..<min(i + minBuckets, valid.count)]
                .allSatisfy { $0.1 >= threshold }

            if sustained {
                peakDates.append(valid[i].0)
            }
        }

        return peakDates
    }
}
