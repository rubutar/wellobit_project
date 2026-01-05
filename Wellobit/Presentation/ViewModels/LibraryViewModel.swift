//
//  BreathingPlayerViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//


import Foundation
import Combine

final class LibraryViewModel: ObservableObject {
    
    @Published var settings: BreathingSettings
    @Published var selectedPhase: BreathingPhase? = nil
    
    @Published var selectedPreset: BreathingPreset = .box
    @Published var cycleCount: Int = 1

    
    
    private let updateUseCase = UpdateBreathingSettingUseCase()
    private let repository: BreathingRepository
    
    init(repository: BreathingRepository, initial: BreathingSettings) {
        self.repository = repository
        self.settings = initial
    }
    
    func select(_ phase: BreathingPhase) {
        selectedPhase = phase
    }
    
    func closeSelection() {
        selectedPhase = nil
    }
    
    func update(phase: BreathingPhase, value: Double) {
//        let stepped = (value * 5).rounded() / 5
        let stepped = Double(Int(round(value)))
        settings = updateUseCase.execute(settings: settings, phase: phase, value: stepped)
        repository.save(settings: settings)
    }
    
}
