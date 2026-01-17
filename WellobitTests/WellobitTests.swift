//
//  WellobitTests.swift
//  WellobitTests
//
//  Created by Rudi Butarbutar on 15/01/26.
//

@testable import Wellobit

final class MockBreathingRepository: BreathingRepository {
    var settings = BreathingSettings(
        inhale: 4,
        holdIn: 4,
        exhale: 4,
        holdOut: 4
    )
    
    func load() -> BreathingSettings {
        settings
    }
    
    func save(settings: BreathingSettings) {
        self.settings = settings
    }
}
