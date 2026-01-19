//
//  SleepStage+Mock.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 19/01/26.
//

import Foundation

extension SleepStage {

    static let mockStages: [SleepStage] = [
        SleepStage(
            type: .core,
            duration: 3 * 60 * 60   // 3 hours
        ),
        SleepStage(
            type: .deep,
            duration: 2 * 60 * 60   // 2 hours
        ),
        SleepStage(
            type: .rem,
            duration: 2 * 60 * 60   // 2 hours
        )
    ]
}
