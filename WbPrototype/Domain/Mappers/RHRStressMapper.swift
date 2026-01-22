//
//  HRStressMapper.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 12/01/26.
//


import Foundation

struct HRStressMapper {

    /// Normalize Resting Heart Rate into a 0–100 stress-like value
    static func normalize(
        hr: Double,
        baselineHR: Double
    ) -> Double {

        let value = (hr - baselineHR) * 3 + 50
        return min(max(value, 0), 100)
    }
}
