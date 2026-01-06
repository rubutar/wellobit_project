//
//  BreathingLiveActivityAttributes.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 06/01/26.
//

import ActivityKit

//struct BreathingLiveActivityAttributes: ActivityAttributes {
//    public struct ContentState: Codable, Hashable {
//        let phase: String
//        let remainingSeconds: Int
//    }
//    
//    let totalCycles: Int
//}


struct BreathingLiveActivityAttributes: ActivityAttributes {

    public struct ContentState: Codable, Hashable {
        let phase: String
        let remainingSeconds: Int
        let phaseTotalSeconds: Int   // ✅ dynamic per phase
    }

    let totalCycles: Int
}
