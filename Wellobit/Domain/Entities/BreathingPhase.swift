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
