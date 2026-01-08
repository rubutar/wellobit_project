//
//  LocalBreathingRepository.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 05/01/26.
//

import Foundation


final class LocalBreathingRepository: BreathingRepository {
    
    private let key = "breathing_settings"
    private let settingsKey = "breathing_settings"
    private let sceneKey = "breathing_scene"
    
    func save(settings: BreathingSettings) {
        let data = [
            "inhale": settings.inhale,
            "holdIn": settings.holdIn,
            "exhale": settings.exhale,
            "holdOut": settings.holdOut
        ]
        
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func load() -> BreathingSettings {
        if let data = UserDefaults.standard.dictionary(forKey: key) as? [String: Double] {
            return BreathingSettings(
                inhale: data["inhale"] ?? 2.0,
                holdIn: data["holdIn"] ?? 3.0,
                exhale: data["exhale"] ?? 3.0,
                holdOut: data["holdOut"] ?? 2.0
            )
        }
        
        // default values if first time open
        return BreathingSettings(inhale: 2, holdIn: 3, exhale: 3, holdOut: 2)
    }
}
