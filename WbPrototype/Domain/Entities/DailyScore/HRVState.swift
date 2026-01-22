//
//  HRVState.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 19/01/26.
//


enum HRVState {
    case low
    case normal
    case high
    case undefined(reason: UndefinedReason)
}

enum UndefinedReason {
    case extremeValue
    case aboveBaselineTooMuch
    case overtraining
    case physiologicalAdaptation
    case measurementArtifact
    case noClearPattern
}

enum HRContext {
    case low
    case normal
    case high
}

struct HRVInterpretation {
    let state: HRVState
    let context: HRContext
    let label: String          // e.g. "Good Recovery"
    let message: String        // user-facing copy
}

struct HRVInterpretationInput {

    let rmssdToday: Double
    let rmssdBaseline: Double

    let sdnnToday: Double
    let sdnnBaseline: Double

    let restingHR: Double
    let hrBaseline: Double

    let aboveBaselineTooMuchStreak: Int
    let extremeValueDaysStreak: Int

    let occurredDuringSleep: Bool
    let occurredDuringWaking: Bool
    let repeatedWithin24h: Bool
}
