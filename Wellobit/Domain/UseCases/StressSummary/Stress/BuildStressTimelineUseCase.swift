//
//  BuildStressTimelineUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 12/01/26.
//


//
//  BuildStressTimelineUseCase.swift
//  Wellobit
//

import Foundation

final class BuildStressTimelineUseCase {
    private let bucketMinutes = 10

    struct Input {
        let startDate: Date
        let endDate: Date

        /// HRV samples already converted to stress anchors (0–100)
        let hrvAnchors: [(date: Date, value: Double)]

        /// Heart Rate samples (BPM)
        let heartRates: [(date: Date, bpm: Double)]

        /// Sleep sessions
        let sleepSessions: [SleepSession]
    }

    private func buildTimeSpine(
        start: Date,
        end: Date
    ) -> [Date] {

        var dates: [Date] = []
        var current = start

        let calendar = Calendar.current

        while current <= end {
            dates.append(current)
            current = calendar.date(
                byAdding: .minute,
                value: bucketMinutes,
                to: current
            )!
        }

        return dates
    }
    
    func execute(input: Input) -> [StressState] {

        let timeline = buildTimeSpine(
            start: input.startDate,
            end: input.endDate
        )

        var states: [StressState] = []
        var currentStress: Double = 50   // starting neutral baseline

        for date in timeline {

            let hasHRV = hrvAnchor(near: date, anchors: input.hrvAnchors) != nil
            let hasHR  = heartRate(near: date, samples: input.heartRates) != nil
            let sleeping = isSleeping(at: date, sessions: input.sleepSessions)

            let hasEnoughData = hasHRV || hasHR || sleeping

            // ❌ NO DATA → break the line
            guard hasEnoughData else {
                states.append(
                    StressState(
                        date: date,
                        value: nil,              // ← THIS breaks the line
                        source: .noData
                    )
                )
                continue
            }

            // 1️⃣ Sleep overrides everything
            if sleeping {
                currentStress = max(currentStress - 3, 15)
                states.append(
                    StressState(
                        date: date,
                        value: currentStress,
                        source: .sleepRecovery
                    )
                )
                continue
            }

            // 2️⃣ HRV anchor snaps stress
            if let hrvValue = hrvAnchor(
                near: date,
                anchors: input.hrvAnchors
            ) {
                currentStress = hrvValue
                states.append(
                    StressState(
                        date: date,
                        value: currentStress,
                        source: .hrvAnchor
                    )
                )
                continue
            }

            // 3️⃣ HR-based propagation (ONLY if HR exists)
            if let hr = heartRate(
                near: date,
                samples: input.heartRates
            ) {
                let baselineHR = 60.0
                let delta = hr - baselineHR
                currentStress += delta * 0.2
            }

            currentStress = clamp(currentStress)

            states.append(
                StressState(
                    date: date,
                    value: currentStress,
                    source: .hrPropagation
                )
            )
        }

        
//        for date in timeline {
//
//            // 1. Sleep overrides everything
//            if isSleeping(at: date, sessions: input.sleepSessions) {
//                currentStress = max(currentStress - 3, 15)
//                states.append(
//                    StressState(
//                        date: date,
//                        value: currentStress,
//                        source: .sleepRecovery
//                    )
//                )
//                continue
//            }
//
//            // 2. HRV anchor snaps stress
//            if let hrvValue = hrvAnchor(
//                near: date,
//                anchors: input.hrvAnchors
//            ) {
//                currentStress = hrvValue
//                states.append(
//                    StressState(
//                        date: date,
//                        value: currentStress,
//                        source: .hrvAnchor
//                    )
//                )
//                continue
//            }
//
//            // 3. HR-based propagation
//            if let hr = heartRate(
//                near: date,
//                samples: input.heartRates
//            ) {
//
//                // TEMP baseline (replace later with personalized baseline)
//                let baselineHR = 60.0
//                let delta = hr - baselineHR
//
//                // Gentle drift
//                currentStress += delta * 0.2
//            } else {
//                // Natural recovery when no signal
//                currentStress -= 0.2
//                currentStress = max(currentStress, 25)
//            }
//
//            currentStress = clamp(currentStress)
//
//            states.append(
//                StressState(
//                    date: date,
//                    value: currentStress,
//                    source: .hrPropagation
//                )
//            )
//        }
        return smooth(states)
    }

    private func hrvAnchor(
        near date: Date,
        anchors: [(date: Date, value: Double)],
        toleranceMinutes: Int = 15
    ) -> Double? {

        let tolerance = TimeInterval(toleranceMinutes * 60)

        return anchors
            .filter { abs($0.date.timeIntervalSince(date)) <= tolerance }
            .sorted {
                abs($0.date.timeIntervalSince(date)) <
                abs($1.date.timeIntervalSince(date))
            }
            .first?
            .value
    }
    
    private func heartRate(
        near date: Date,
        samples: [(date: Date, bpm: Double)],
        toleranceMinutes: Int = 5
    ) -> Double? {

        let tolerance = TimeInterval(toleranceMinutes * 60)

        return samples
            .filter { abs($0.date.timeIntervalSince(date)) <= tolerance }
            .sorted {
                abs($0.date.timeIntervalSince(date)) <
                abs($1.date.timeIntervalSince(date))
            }
            .first?
            .bpm
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, 0), 100)
    }
    
    private func isSleeping(
        at date: Date,
        sessions: [SleepSession]
    ) -> Bool {
        sessions.contains { session in
            date >= session.startDate && date <= session.endDate
        }
    }

    private func smooth(
        _ states: [StressState],
        alpha: Double = 0.2
    ) -> [StressState] {

        var result: [StressState] = []
        var previousValue: Double?

        for state in states {

            // Gap → keep nil and reset smoothing
            guard let value = state.value else {
                result.append(state)
                previousValue = nil
                continue
            }

            if let prev = previousValue {
                let smoothed = alpha * value + (1 - alpha) * prev
                previousValue = smoothed

                result.append(
                    StressState(
                        date: state.date,
                        value: smoothed,
                        source: state.source
                    )
                )
            } else {
                // Start of a new valid segment
                previousValue = value
                result.append(state)
            }
        }

        return result
    }


}
