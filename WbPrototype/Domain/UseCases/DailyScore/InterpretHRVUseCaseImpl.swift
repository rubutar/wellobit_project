//
//  InterpretHRVUseCaseImpl.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 19/01/26.
//

import Foundation

protocol InterpretHRVUseCase {
    func execute(input: HRVInterpretationInput) -> HRVInterpretation
}

final class InterpretHRVUseCaseImpl: InterpretHRVUseCase {

    func execute(input: HRVInterpretationInput) -> HRVInterpretation {
        if hasInsufficientData(input) {
            return HRVInterpretation(
                state: .undefined(reason: .noClearPattern),
                context: .normal,
                label: "No Data Found",
                message: "This may be because your Apple Watch wasn’t worn long enough or health permissions are not enabled."
            )
        }

        let state = determineHRVState(input)
        let context = determineHRContext(input)

        return buildInterpretation(
            state: state,
            context: context,
            input: input
        )
    }
}

private extension InterpretHRVUseCaseImpl {
    func determineHRVState(_ input: HRVInterpretationInput) -> HRVState {

        if input.isRest && (input.rmssdToday > 200 || input.rmssdToday < 5) {
            return .undefined(reason: .extremeValue)
        }

        if input.isRest && (input.sdnnToday >= 150 || input.sdnnToday < 5) {
            return .undefined(reason: .extremeValue)
        }
        if input.isRest && (input.currentHR > 130 || input.currentHR < 40) {
            return .undefined(reason: .extremeValue)
        }

        if input.isRest && hasContradictoryRestTrends(
            hrSamples: input.hrSamples,
            hrvPoints: input.hrvSamples
        ) {
            return .undefined(reason: .contradictoryTrends)
        }
//        if input.c

//        if input.rmssdToday >= input.rmssdBaseline * 1.5 {
//            return .undefined(reason: .aboveBaselineTooMuch)
//        }
//
//        if input.sdnnToday >= input.sdnnBaseline * 1.5 {
//            return .undefined(reason: .aboveBaselineTooMuch)
//        }

        let ratio = input.rmssdToday / input.rmssdBaseline

        switch ratio {
        case ..<0.9:
            return .low
        case 0.9...1.1:
            return .normal
        default:
            return .high
        }
    }
    
    func hasInsufficientData(_ input: HRVInterpretationInput) -> Bool {
        input.rmssdToday <= 0 ||
        input.sdnnToday <= 0 ||
        input.currentHR <= 0 ||
        input.hrBaseline <= 0
    }

}

private extension InterpretHRVUseCaseImpl {

    func determineHRContext(_ input: HRVInterpretationInput) -> HRContext {

        let ratio = input.currentHR / input.hrBaseline

        switch ratio {
        case ..<0.9:
            return .low
        case 0.9...1.1:
            return .normal
        default:
            return .high
        }
    }
}

private extension InterpretHRVUseCaseImpl {

    func resolveUndefined(_ input: HRVInterpretationInput) -> UndefinedReason {

        if input.occurredDuringSleep &&
            input.aboveBaselineTooMuchStreak >= 2 {
            return .overtraining
        }
        return .noClearPattern
    }
}

private extension InterpretHRVUseCaseImpl {

    func buildInterpretation(
        state: HRVState,
        context: HRContext,
        input: HRVInterpretationInput
    ) -> HRVInterpretation {

        switch state {
        case .undefined(let reason):

            return HRVInterpretation(
                state: .undefined(reason: reason),
                context: context,
                label: "Undefined",
                message: messageForUndefined(reason, input: input)
            )

        case .low:
            switch context {
            case .high:
                return .init(
                    state: .low,
                    context: .high,
                    label: "Acute Stress",
                    message: "Your recovery is suppressed and heart rate is elevated, suggesting acute stress or fatigue."
                )

            case .normal, .low:
                return .init(
                    state: .low,
                    context: context,
                    label: "Accumulated Fatigue",
                    message: "Your recovery signal is low, likely due to accumulated fatigue."
                )
            }

        case .normal:
            switch context {
            case .high:
                return .init(
                    state: .normal,
                    context: .high,
                    label: "Coping Under Load",
                    message: "Your heart rate is elevated, but recovery remains stable."
                )

            case .normal:
                return .init(
                    state: .normal,
                    context: .normal,
                    label: "Stable",
                    message: "Your recovery and heart rate are in line with your usual pattern."
                )

            case .low:
                return .init(
                    state: .normal,
                    context: .low,
                    label: "Calm",
                    message: "Your body appears calm and well regulated today."
                )
            }

        case .high:
            switch context {
            case .low:
                return .init(
                    state: .high,
                    context: .low,
                    label: "Good Recovery",
                    message: "Your recovery signal is strong and heart rate is low."
                )

            case .normal:
                return .init(
                    state: .high,
                    context: .normal,
                    label: "Good Recovery / Readiness",
                    message: "Your recovery is elevated and heart rate is within your normal range."
                )

            case .high:
                return .init(
                    state: .high,
                    context: .high,
                    label: "Adaptation",
                    message: "Your recovery remains high despite elevated heart rate, suggesting positive adaptation."
                )
            }
        }
    }
}

private extension InterpretHRVUseCaseImpl {

    func messageForUndefined(
        _ reason: UndefinedReason,
        input: HRVInterpretationInput
    ) -> String {
        switch reason {
        case .extremeValue:
            return extremeValueMessage(for: input)
        case .aboveBaselineTooMuch:
            let resolved = resolveUndefined(input)
            if resolved == .overtraining {
                return "Your recovery signal has been elevated for multiple days during sleep. Consider prioritizing rest and reducing training intensity for now."
            } else {
                return fallbackDefinedMessage(state: determineDefinedState(input),
                                              context: determineHRContext(input))
            }
        case .overtraining:
            return "This pattern may indicate overtraining. Consider rest."
        case .physiologicalAdaptation:
            return "This pattern may reflect physiological adaptation."
        case .measurementArtifact:
            return "This HRV reading may be a measurement artifact."
        case .noClearPattern:
            return "No clear recovery pattern detected."
        case .contradictoryTrends:
            return "Contradictory trends."

        }
    }
    func extremeValueMessage(for input: HRVInterpretationInput) -> String {
        if input.extremeValueDaysStreak >= 3 {
            return "Your HRV values have been unusually high for several days. Consider consulting a medical professional."
        } else {
            return "Your HRV values are unusually high. This may reflect physiological adaptation, especially in well-trained individuals."
        }
    }
    func determineDefinedState(_ input: HRVInterpretationInput) -> HRVState {
        let ratio = input.rmssdToday / input.rmssdBaseline

        switch ratio {
        case ..<0.9:
            return .low
        case 0.9...1.1:
            return .normal
        default:
            return .high
        }
    }
    func fallbackDefinedMessage(
        state: HRVState,
        context: HRContext
    ) -> String {
        switch (state, context) {
        case (.normal, .normal):
            return "Your recovery and heart rate are in line with your usual pattern."
        case (.high, .normal):
            return "Your recovery is elevated and heart rate is within your normal range."
        case (.high, .low):
            return "Your recovery signal is strong and heart rate is low."
        case (.low, .high):
            return "Your recovery is suppressed and heart rate is elevated."
        default:
            return "Your recovery appears within a normal range today."
        }
    }

}

//CHECK TRENDS
private extension InterpretHRVUseCaseImpl {
    private func splitIntoThirds(_ values: [Double]) -> ([Double], [Double], [Double]) {
        let count = values.count
        guard count >= 6 else { return ([], [], []) }

        let third = count / 3
        return (
            Array(values[0..<third]),
            Array(values[third..<(2 * third)]),
            Array(values[(2 * third)..<count])
        )
    }

    private func isIncreasing(_ values: [Double]) -> Bool {
        let (a, b, c) = splitIntoThirds(values)
        guard !a.isEmpty, !b.isEmpty, !c.isEmpty else { return false }

        let m1 = a.reduce(0, +) / Double(a.count)
        let m2 = b.reduce(0, +) / Double(b.count)
        let m3 = c.reduce(0, +) / Double(c.count)

        return m1 < m2 && m2 < m3
    }

//    private func hasContradictoryRestTrends(
//        hrSamples: [HeartRateSample],
//        hrvPoints: [HRVPoint],
//        hrvType: HRVType = .sdnn
//    ) -> Bool {
//
//        let hrValues = sortedHRValues(from: hrSamples)
//        let hrvValues = sortedValues(from: hrvPoints, type: hrvType)
//
//        guard hrValues.count >= 6, hrvValues.count >= 6 else {
//            return false
//        }
//        return isIncreasing(hrValues) && isIncreasing(hrvValues)
//    }
    private func hasContradictoryRestTrends(
        hrSamples: [HeartRateSample],
        hrvPoints: [HRVPoint],
        hrvType: HRVType = .sdnn
    ) -> Bool {

        let hrValues = sortedHRValues(from: hrSamples)
        let hrvValues = sortedValues(from: hrvPoints, type: hrvType)

        // 🔍 RAW INPUT
        print("🧪 [TrendCheck] HR raw samples:")
        hrSamples.forEach {
            print("   \(formatted($0.date)) → \($0.bpm)")
        }

        print("🧪 [TrendCheck] HRV raw samples (\(hrvType)):")
        hrvPoints
            .filter { $0.type == hrvType }
            .forEach {
                print("   \(formatted($0.date)) → \($0.value)")
            }

        // 🔍 SORTED VALUES
        print("📈 [TrendCheck] HR sorted values:", hrValues)
        print("📈 [TrendCheck] HRV sorted values:", hrvValues)

        guard hrValues.count >= 6, hrvValues.count >= 6 else {
            print("⚠️ [TrendCheck] Not enough samples (HR: \(hrValues.count), HRV: \(hrvValues.count))")
            return false
        }

        let hrIncreasing = isIncreasing(hrValues)
        let hrvIncreasing = isIncreasing(hrvValues)

        print("📊 [TrendCheck] HR increasing:", hrIncreasing)
        print("📊 [TrendCheck] HRV increasing:", hrvIncreasing)

        let result = hrIncreasing && hrvIncreasing
        print("🚨 [TrendCheck] Contradictory rest trends:", result)

        return result
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }


    private func sortedValues(from hrvPoints: [HRVPoint], type: HRVType) -> [Double] {
        hrvPoints
            .filter { $0.type == type }
            .sorted { $0.date < $1.date }
            .map(\.value)
    }

    private func sortedHRValues(from hrSamples: [HeartRateSample]) -> [Double] {
        hrSamples
            .sorted { $0.date < $1.date }
            .map(\.bpm)
    }

}
