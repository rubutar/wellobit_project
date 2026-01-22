//
//  SleepStageType.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


import Foundation
import HealthKit

enum SleepStageType {
    case awake
    case rem
    case core
    case deep

    init?(from hkValue: Int) {
        switch hkValue {
        case HKCategoryValueSleepAnalysis.awake.rawValue:
            self = .awake
        case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
            self = .rem
        case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
            self = .core
        case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
            self = .deep
        default:
            return nil
        }
    }
}


struct SleepStage {
    let type: SleepStageType
    let duration: TimeInterval
}
