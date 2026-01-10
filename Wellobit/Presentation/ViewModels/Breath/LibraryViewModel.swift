//
//  BreathingPlayerViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//


import Foundation
import Combine
import SwiftUI

@MainActor
final class LibraryViewModel: ObservableObject {

    // MARK: - Published
    @Published var settings: BreathingSettings
    @Published var selectedPhase: BreathingPhase? = nil

    @Published var selectedPreset: BreathingPreset = .custom {
        didSet {
            applyPresetIfNeeded()
        }
    }

    @Published var cycleCount: Int = 4

    // Navigation state is owned here, rendered by LibraryView
    @Published var navigationPath = NavigationPath()


    // MARK: - Dependencies
    private let updateUseCase = UpdateBreathingSettingUseCase()
    private let repository: BreathingRepository

    // MARK: - Init
    init(repository: BreathingRepository, initial: BreathingSettings) {
        self.repository = repository
        self.settings = initial
    }

    // MARK: - Navigation Intents
    func openScenes() {
        navigationPath.append(LibraryDestination.scenes)
    }

    func closeCurrentScreen() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
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

        // Manual edit → Custom preset
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
            return
        }

        settings = presetSettings
        repository.save(settings: settings)
    }
    func durationString(for cycles: Int) -> String {
        let phaseTotal =
            settings.inhale +
            settings.holdIn +
            settings.exhale +
            settings.holdOut

        let totalSeconds = Int(Double(cycles) * phaseTotal)

        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return "\(minutes)m \(seconds)s"
    }
    var totalDurationSeconds: Int {
        let phaseTotal =
            settings.inhale +
            settings.holdIn +
            settings.exhale +
            settings.holdOut

        return Int(Double(cycleCount) * phaseTotal)
    }
    
}
