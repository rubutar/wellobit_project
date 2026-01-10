//
//  SleepStageType.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


import Foundation

enum SleepStageType {
    case awake
    case rem
    case core
    case deep
}

struct SleepStage {
    let type: SleepStageType
    let duration: TimeInterval
}
