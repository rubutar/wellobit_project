//
//  HRVToStressMapper.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


struct HRVToStressMapper {

    static func stressScore(from hrv: Double) -> Int {
        switch hrv {
        case ..<20: return 90
        case 20..<30: return 75
        case 30..<40: return 60
        case 40..<50: return 45
        case 50..<60: return 30
        default: return 15
        }
    }

    static func stressLevel(from score: Int) -> StressLevel {
        switch score {
        case ..<25: return .low
        case 25..<50: return .medium
        case 50..<75: return .high
        default: return .veryHigh
        }
    }
}
