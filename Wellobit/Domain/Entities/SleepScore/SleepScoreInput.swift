//
//  SleepScoreInput.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import Foundation

struct SleepScoreInput {

    // Sleep
    let sleepDurationHours: Double          // e.g. 6.5
    let bedtime: Date

    // HRV
    let sleepHRV: Double?
    let baselineHRV: Double?

    // Heart rate
    let sleepHeartRate: Double?
    let baselineHeartRate: Double?

    // Consistency
    let averageBedtime: Date?
}
