//
//  RHRStressMapper.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 12/01/26.
//


import Foundation

struct RHRStressMapper {

    /// Normalize Resting Heart Rate into a 0–100 stress-like value
    static func normalize(
        rhr: Double,
        baselineRHR: Double
    ) -> Double {

        let value = (rhr - baselineRHR) * 3 + 50
        return min(max(value, 0), 100)
    }
}
