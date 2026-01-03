//
//  UpdateBreathingSettingUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//


struct UpdateBreathingSettingUseCase {
    func execute(settings: BreathingSettings, phase: BreathingPhase, value: Double) -> BreathingSettings {
        var updated = settings
        
        switch phase {
        case .inhale: updated.inhale = value
        case .holdIn: updated.holdIn = value
        case .exhale: updated.exhale = value
        case .holdOut: updated.holdOut = value
        }
        
        return updated
    }
}
