//
//  BreathingPlayerViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//


import Foundation
import Combine

final class BreathingPlayerViewModel: ObservableObject {

    // MARK: - Published
    @Published private(set) var currentPhase: BreathingPhase?
    @Published private(set) var phaseDuration: TimeInterval = 0
    @Published private(set) var isPlaying = false

    @Published private(set) var currentCycle: Int = 0

    // MARK: - Private
    private let phases: [BreathingPhase] = [.inhale, .holdIn, .exhale, .holdOut]
    private var phaseIndex = 0

    private var phaseTimer: Timer?
    private var debugTimer: Timer?
    @Published private(set) var remainingSeconds: Int = 0


    private let libraryVM: LibraryViewModel
    
    var totalCycles: Int {
        libraryVM.cycleCount
    }

    init(libraryViewModel: LibraryViewModel) {
        self.libraryVM = libraryViewModel
    }

    // MARK: - Public
    func play() {
        guard !isPlaying else { return }

        isPlaying = true
        currentCycle = 1
        phaseIndex = 0
        startPhase()
    }

    func stop() {
        phaseTimer?.invalidate()
        debugTimer?.invalidate()
        phaseTimer = nil
        debugTimer = nil

        currentPhase = nil
        isPlaying = false
        currentCycle = 0
    }

    // MARK: - Engine
    private func startPhase() {
        guard isPlaying else { return }

        // Finished all phases in one cycle
        if phaseIndex >= phases.count {
            phaseIndex = 0
            currentCycle += 1

            if currentCycle > libraryVM.cycleCount {
                stop()
                return
            }
        }

        let phase = phases[phaseIndex]
        currentPhase = phase

        let duration = durationForPhase(phase)
        phaseDuration = duration
        remainingSeconds = Int(duration)

        // 🔍 Debug
        print("🔁 Cycle \(currentCycle)/\(libraryVM.$cycleCount) — \(phase) (\(Int(duration))s)")

        // Phase timer
        phaseTimer?.invalidate()
        phaseTimer = Timer.scheduledTimer(
            withTimeInterval: duration,
            repeats: false
        ) { [weak self] _ in
            guard let self else { return }
            self.debugTimer?.invalidate()
            self.phaseIndex += 1
            self.startPhase()
        }

        // Debug seconds timer
        debugTimer?.invalidate()
        debugTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            self.remainingSeconds -= 1
            if self.remainingSeconds > 0 {
                print("⏱ \(phase): \(self.remainingSeconds)s remaining")
            }
        }
    }

    // MARK: - Helpers
    private func durationForPhase(_ phase: BreathingPhase) -> TimeInterval {
        let s = libraryVM.settings
        switch phase {
        case .inhale: return s.inhale
        case .holdIn: return s.holdIn
        case .exhale: return s.exhale
        case .holdOut: return s.holdOut
        }
    }
}
