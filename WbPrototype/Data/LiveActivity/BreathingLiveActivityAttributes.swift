//
//  BreathingLiveActivityAttributes.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 06/01/26.
//

import ActivityKit
import Foundation

struct BreathingLiveActivityAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        let sessionStart: Date
        let sessionEnd: Date
    }
    let totalCycles: Int
}

