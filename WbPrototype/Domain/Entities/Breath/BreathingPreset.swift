//
//  BreathingPreset.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 05/01/26.
//


enum BreathingPreset: String, CaseIterable, Identifiable {
    case box = "Box Breathing"
    case longExhale = "Long Exhale"
    case cBreath = "Coherent Breath"
    case eBreath = "Energizing Breath"
    case sleep = "Breath For Sleep"
    case fourSevenEight = "4-7-8 Breathing"
    case custom = "Custom"

    var id: String { rawValue }
}


extension BreathingPreset {

    var settings: BreathingSettings? {
        switch self {
        case .box:
            return BreathingSettings(
                inhale: 4,
                holdIn: 4,
                exhale: 4,
                holdOut: 4
            )
        
        case .longExhale:
            return BreathingSettings(
                inhale: 6,
                holdIn: 2,
                exhale: 6,
                holdOut: 2
            )
        
        case .cBreath:
            return BreathingSettings(
                inhale: 5,
                holdIn: 0,
                exhale: 5,
                holdOut: 0
            )
        
        case .eBreath:
            return BreathingSettings(
                inhale: 6,
                holdIn: 3,
                exhale: 6,
                holdOut: 3
            )

        case .sleep:
            return BreathingSettings(
                inhale: 3,
                holdIn: 0,
                exhale: 7,
                holdOut: 0
            )
            
        case .fourSevenEight:
            return BreathingSettings(
                inhale: 4,
                holdIn: 7,
                exhale: 8,
                holdOut: 0
            )



        case .custom:
            return nil
        }
    }
}
