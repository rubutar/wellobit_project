//
//  ComputePeakStressScoreUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 13/01/26.
//

import Foundation

final class ComputePeakStressScoreUseCase {

    private let windowMinutes: Int
    private let normalizationCeiling: Double
    private let minimumWindowCount = 8   // ≈ 4 hours coverage

    init(
        windowMinutes: Int = 30,          // window size
        normalizationCeiling: Double = 85 // physiological reference
    ) {
        self.windowMinutes = windowMinutes
        self.normalizationCeiling = normalizationCeiling
    }

    func execute(states: [StressState]) -> Double? {

        let realDates = states.compactMap { $0.value != nil ? $0.date : nil }

        guard
            let first = realDates.first,
            let last = realDates.last,
            last.timeIntervalSince(first) >= 4 * 60 * 60   // ≥ 4 hours span
        else {
            return nil
        }

        
        // 0️⃣ Require sufficient REAL stress data (not sleep / placeholders)
        let realDataPoints = states.filter { $0.value != nil }

        // Require at least ~2 hours of real data (4 × 30min buckets)
        guard realDataPoints.count >= 4 else {
            return nil
        }

        // 1️⃣ Sort states by time, inject low stress for sleep / missing values
        let sorted = states
            .map { ($0.date, $0.value ?? 15) }
            .sorted { $0.0 < $1.0 }

        guard sorted.count > 1 else { return nil }

        // 2️⃣ Build time-aligned windows
        let windowDuration = TimeInterval(windowMinutes * 60)

        var windowPeaks: [Double] = []
        var windowStart = sorted.first!.0
        var windowEnd = windowStart.addingTimeInterval(windowDuration)

        var currentPeak: Double = 0
        var hasValueInWindow = false

        for (date, value) in sorted {

            if date < windowEnd {
                currentPeak = max(currentPeak, value)
                hasValueInWindow = true
            } else {
                // close window only if it had data
                if hasValueInWindow {
                    windowPeaks.append(currentPeak)
                }

                // advance window until date fits
                while date >= windowEnd {
                    windowStart = windowEnd
                    windowEnd = windowStart.addingTimeInterval(windowDuration)
                }

                // start new window
                currentPeak = value
                hasValueInWindow = true
            }
        }

        // close final window
        if hasValueInWindow {
            windowPeaks.append(currentPeak)
        }

        // 3️⃣ Require sufficient coverage
        guard windowPeaks.count >= minimumWindowCount else {
            return nil
        }

        // 4️⃣ Average window peaks
        let averagePeak =
            windowPeaks.reduce(0, +) / Double(windowPeaks.count)

        // 5️⃣ Normalize to %
        let normalized =
            min(averagePeak, normalizationCeiling)
            / normalizationCeiling * 100

        return normalized
    }
}

