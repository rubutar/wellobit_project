//
//  BreathingPlayerViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//


import Foundation
import Combine
import AVFoundation
import UIKit

// MARK: - Presentation State
enum PlayerUIState: Equatable {
    case idle
    case preparing(seconds: Int)
    case breathing
    case completed
}

final class BreathingPlayerViewModel: ObservableObject {

    // MARK: - Published (UI-facing)
    @Published private(set) var uiState: PlayerUIState = .idle
    @Published private(set) var currentPhase: BreathingPhase?
    @Published private(set) var phaseDuration: TimeInterval = 0
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var currentCycle: Int = 0
    

    @Published private(set) var isPlaying = false
    @Published private(set) var isPaused = false
    @Published var isMuted = false
    private var cancellables = Set<AnyCancellable>()


    // MARK: - Configuration
    private let preparationSeconds = 3
    private let phases: [BreathingPhase] = [.inhale, .holdIn, .exhale, .holdOut]

    // MARK: - Time / Engine
    private var sessionStartDate: Date?
    private var phaseIndex = 0

    // MARK: - Timers
    private var phaseTimer: Timer?
    private var secondTimer: Timer?

    // MARK: - Audio
    private var audioPlayer: AVAudioPlayer?
    private var cuePlayer: AVAudioPlayer?


    // MARK: - Dependencies
    private let libraryVM: LibraryViewModel

    var totalCycles: Int {
        libraryVM.cycleCount
    }

    // MARK: - Init
    init(libraryViewModel: LibraryViewModel) {
        self.libraryVM = libraryViewModel
        configureAudioSession()
        bindConfigurationChanges()
    }

    // MARK: - Public Controls

    private func bindConfigurationChanges() {

        // Observe breathing phase values
        libraryVM.$settings
            .dropFirst()              // ignore initial value
            .sink { [weak self] _ in
                self?.handleConfigurationChange()
            }
            .store(in: &cancellables)

        // Observe cycle count
        libraryVM.$cycleCount
            .dropFirst()
            .sink { [weak self] _ in
                self?.handleConfigurationChange()
            }
            .store(in: &cancellables)
    }

    private func handleConfigurationChange() {
        guard isPlaying || uiState != .idle else { return }

        // Reset session because configuration is no longer valid
        stop()
    }
    
    func play() {
        guard !isPlaying else { return }

        isPlaying = true
        isPaused = false
        uiState = .preparing(seconds: preparationSeconds)

        startPreparationCountdown()
    }

    func stop() {
        invalidateTimers()
        stopAudio()

        currentPhase = nil
        remainingSeconds = 0
        currentCycle = 0
        isPlaying = false
        isPaused = false
        uiState = .idle
    }

    func pause() {
        guard isPlaying, !isPaused else { return }

        isPaused = true
        invalidateTimers()
        audioPlayer?.pause()
    }

    func resume() {
        guard isPlaying, isPaused else { return }

        isPaused = false
        resumeCurrentPhase()

        if !isMuted {
            audioPlayer?.play()
        }
    }

    func toggleMute() {
        isMuted.toggle()

        if isMuted {
            stopAudio()
        } else if isPlaying && !isPaused {
            startAudio()
        }
    }

    // MARK: - Preparation

    private func startPreparationCountdown() {
        remainingSeconds = preparationSeconds
        invalidateTimers()

        secondTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] timer in
            guard let self else { return }

            if self.remainingSeconds <= 1 {
                timer.invalidate()
                self.startBreathingSession()
            } else {
                self.remainingSeconds -= 1
                self.uiState = .preparing(seconds: self.remainingSeconds)
            }
        }
    }

    // MARK: - Breathing Session

    private func startBreathingSession() {
        uiState = .breathing

        sessionStartDate = Date()
        startAudio()

        currentCycle = 1
        phaseIndex = 0
        startPhase()
    }

    private func startPhase() {
        guard isPlaying, !isPaused else { return }

        if phaseIndex >= phases.count {
            phaseIndex = 0
            currentCycle += 1

            if currentCycle > libraryVM.cycleCount {
                finishSession()
                return
            }
        }

        let phase = phases[phaseIndex]
        currentPhase = phase
        playCue(for: phase)

        let duration = durationForPhase(phase)
        phaseDuration = duration
        remainingSeconds = Int(duration)

        invalidateTimers()

        phaseTimer = Timer.scheduledTimer(
            withTimeInterval: duration,
            repeats: false
        ) { [weak self] _ in
            guard let self else { return }
            self.phaseIndex += 1
            self.startPhase()
        }

        secondTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            }
        }
    }

    private func resumeCurrentPhase() {
        guard let phase = currentPhase else { return }

        let remaining = TimeInterval(remainingSeconds)
        invalidateTimers()

        phaseTimer = Timer.scheduledTimer(
            withTimeInterval: remaining,
            repeats: false
        ) { [weak self] _ in
            guard let self else { return }
            self.phaseIndex += 1
            self.startPhase()
        }

        secondTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            }
        }
    }

    // MARK: - Completion

    private func finishSession() {
        invalidateTimers()
        stopAudio()

        currentPhase = nil
        isPlaying = false
        isPaused = false
        uiState = .completed
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

    private func invalidateTimers() {
        phaseTimer?.invalidate()
        secondTimer?.invalidate()
        phaseTimer = nil
        secondTimer = nil
    }

    // MARK: - Audio

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try session.setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }

    private func startAudio() {
        guard !isMuted else { return }

        guard let url = Bundle.main.url(forResource: "birds", withExtension: "mp3") else {
            print("birds.mp3 not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Audio error:", error)
        }
    }
    
    private func playCue(for phase: BreathingPhase) {
        guard !isMuted else { return }

        guard let name = cueSoundName(for: phase),
              let url = Bundle.main.url(forResource: name, withExtension: "mpeg") else {
            return
        }

        do {
            cuePlayer = try AVAudioPlayer(contentsOf: url)
            cuePlayer?.volume = 1.0
            cuePlayer?.play()
        } catch {
            print("Cue sound error:", error)
        }
    }

    private func cueSoundName(for phase: BreathingPhase) -> String? {
        switch phase {
        case .inhale:
            return "inhale"
        case .exhale:
            return "exhale"
        case .holdIn, .holdOut:
            return "hold"
        }
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
