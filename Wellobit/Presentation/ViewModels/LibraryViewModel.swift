//
//  BreathingPlayerViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//


import Foundation
import Combine

final class LibraryViewModel: ObservableObject {

    // MARK: - Published
    @Published var settings: BreathingSettings
    @Published var selectedPhase: BreathingPhase? = nil

    // ✅ Default preset is Custom
    @Published var selectedPreset: BreathingPreset = .custom {
        didSet {
            applyPresetIfNeeded()
        }
    }

    @Published var cycleCount: Int = 4

    // MARK: - Dependencies
    private let updateUseCase = UpdateBreathingSettingUseCase()
    private let repository: BreathingRepository

    // MARK: - Init
    init(repository: BreathingRepository, initial: BreathingSettings) {
        self.repository = repository
        self.settings = initial
    }

    // MARK: - UI Actions
    func select(_ phase: BreathingPhase) {
        selectedPhase = phase
    }

    func closeSelection() {
        selectedPhase = nil
    }

    func update(phase: BreathingPhase, value: Double) {
        let stepped = Double(Int(round(value)))

        // ✅ If user edits manually, switch to Custom
        if selectedPreset != .custom {
            selectedPreset = .custom
        }

        settings = updateUseCase.execute(
            settings: settings,
            phase: phase,
            value: stepped
        )

        repository.save(settings: settings)
    }

    // MARK: - Preset Logic
    private func applyPresetIfNeeded() {
        guard let presetSettings = selectedPreset.settings else {
            return // Custom → do nothing
        }

        settings = presetSettings
        repository.save(settings: settings)
    }
}
