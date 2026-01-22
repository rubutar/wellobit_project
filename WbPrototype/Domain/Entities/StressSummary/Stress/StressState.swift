//
//  StressState.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 12/01/26.
//


//
//  StressState.swift
//  Wellobit
//

import Foundation

struct StressState: Identifiable {
    let id = UUID()

    let date: Date

    /// Final modeled stress value (0–100)
    let value: Double?

    /// Where this value came from (debug / insight)
    let source: Source

    enum Source {
        case hrvAnchor      // HRV-based recalibration
        case hrPropagation  // HR-based drift
        case sleepRecovery  // Sleep-driven recovery
        case noData
    }
}
