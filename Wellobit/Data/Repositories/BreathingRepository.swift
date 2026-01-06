//
//  BreathingRepository.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import Foundation


protocol BreathingRepository {
    func save(settings: BreathingSettings)
    func load() -> BreathingSettings
}
