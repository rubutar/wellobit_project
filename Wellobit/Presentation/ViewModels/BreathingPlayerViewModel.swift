//
//  BreathingPlayerViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//


import Foundation
import Combine
import AVFoundation


enum PlayerUIState: Equatable {
    case idle
    case preparing(seconds: Int)
    case breathing
    case completed
}

final class BreathingPlayerViewModel: ObservableObject {

    // MARK: - Published
    @Published private(set) var currentPhase: BreathingPhase?
    @Published private(set) var phaseDuration: TimeInterval = 0
    @Published private(set) var isPlaying = false
    @Published var isMuted: Bool = false
    @Published private(set) var isPaused: Bool = false
    @Published private(set) var uiState: PlayerUIState = .idle
    private let preparationSeconds = 3



    

    @Published private(set) var currentCycle: Int = 0

    // MARK: - Private
    private let phases: [BreathingPhase] = [.inhale, .holdIn, .exhale, .holdOut]
    private var phaseIndex = 0

    private var phaseTimer: Timer?
    private var debugTimer: Timer?
    private var audioPlayer: AVAudioPlayer?

    @Published private(set) var remainingSeconds: Int = 0


    private let libraryVM: LibraryViewModel
    
    var totalCycles: Int {
        libraryVM.cycleCount
    }

    init(libraryViewModel: LibraryViewModel) {
        self.libraryVM = libraryViewModel
    }

    // MARK: - Public
  
    func toggleMute() {
        isMuted.toggle()

        if isMuted {
            stopAudio()
        } else if isPlaying && !isPaused {
            startAudio()
        }
    }
    
//    func toggleMute() {
//        isMuted.toggle()
//
//        if isMuted {
//            stopAudio()
//        } else if isPlaying {
//            startAudio()
//        }
//    }
//    
//    func play() {
//        guard !isPlaying else { return }
//
//        isPlaying = true
//        isPaused = false
//
//        startAudio()
//
//        currentCycle = 1
//        phaseIndex = 0
//        startPhase()
//    }
    
    
    func play() {
        guard !isPlaying else { return }

        isPlaying = true
        isPaused = false
        uiState = .preparing(seconds: preparationSeconds)

        startPreparationCountdown()
    }

    private func startPreparationCountdown() {
        remainingSeconds = preparationSeconds

        invalidateTimers()

        debugTimer = Timer.scheduledTimer(
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
    
    private func startBreathingSession() {
        uiState = .breathing

        startAudio()

        currentCycle = 1
        phaseIndex = 0
        startPhase()
    }
    
//    func stop() {
//        phaseTimer?.invalidate()
//        debugTimer?.invalidate()
//        phaseTimer = nil
//        debugTimer = nil
//        
//        stopAudio()
//
//        currentPhase = nil
//        remainingSeconds = 0
//        isPlaying = false
//        isPaused = false
//        currentCycle = 0
//    }
    func stop() {
        invalidateTimers()
        stopAudio()

        currentPhase = nil
        remainingSeconds = 0
        isPlaying = false
        isPaused = false
        currentCycle = 0
        uiState = .idle
    }

    
    func pause() {
        guard isPlaying, !isPaused else { return }

        isPaused = true
        pauseTimers()
        audioPlayer?.pause()
    }

    func resume() {
        guard isPlaying, isPaused else { return }

        isPaused = false
        resumePhase()

        if !isMuted {
            audioPlayer?.play()
        }
    }

    
    // MARK: - Engine
    private func startPhase() {
        guard isPlaying else { return }

        // Finished all phases in one cycle
        if phaseIndex >= phases.count {
            phaseIndex = 0
            currentCycle += 1

//            if currentCycle > libraryVM.cycleCount {
//                stop()
//                return
//            }
            
            if currentCycle > libraryVM.cycleCount {
                finishSession()
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
    
    private func finishSession() {
        stopAudio()
        invalidateTimers()

        currentPhase = nil
        isPlaying = false
        isPaused = false
        uiState = .completed
    }
    
    private func invalidateTimers() {
        phaseTimer?.invalidate()
        debugTimer?.invalidate()
        phaseTimer = nil
        debugTimer = nil
    }
    
    private func durationForPhase(_ phase: BreathingPhase) -> TimeInterval {
        let s = libraryVM.settings
        switch phase {
        case .inhale: return s.inhale
        case .holdIn: return s.holdIn
        case .exhale: return s.exhale
        case .holdOut: return s.holdOut
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

    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    private func pauseTimers() {
        phaseTimer?.invalidate()
        debugTimer?.invalidate()
        phaseTimer = nil
        debugTimer = nil
    }

    private func resumePhase() {
        guard let phase = currentPhase else { return }

        // Resume phase timer with remaining time
        phaseTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(remainingSeconds),
            repeats: false
        ) { [weak self] _ in
            guard let self else { return }
            self.debugTimer?.invalidate()
            self.phaseIndex += 1
            self.startPhase()
        }

        // Resume second countdown
        debugTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            self.remainingSeconds -= 1
        }
    }

}
