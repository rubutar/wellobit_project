//
//  BreathingPhase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

enum BreathingPhase: String {
    case inhale
    case holdIn
    case exhale
    case holdOut
}

enum BreathingPreset: String, CaseIterable, Identifiable {
    case box = "Box Breathing"
    case fourSevenEight = "4-7-8 Breathing"
    case awake = "Awake"
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

        case .fourSevenEight:
            return BreathingSettings(
                inhale: 4,
                holdIn: 7,
                exhale: 8,
                holdOut: 0
            )

        case .awake:
            return BreathingSettings(
                inhale: 6,
                holdIn: 0,
                exhale: 2,
                holdOut: 0
            )

        case .custom:
            return nil
        }
    }
}
