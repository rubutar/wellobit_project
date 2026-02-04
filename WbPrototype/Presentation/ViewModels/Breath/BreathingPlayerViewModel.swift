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
    @Published var isResting: Bool {
        didSet {
            UserDefaults.standard.set(isResting, forKey: RestKeys.isResting)
        }
    }
    private var restResetWorkItem: DispatchWorkItem?
    @Published var showBadgePopup = false
    @Published private(set) var remainingSessionSeconds: Int = 0
    private var sessionTimer: Timer?
    
    @Published private(set) var phaseProgress: Double = 0.0
    
    @Published var isHapticsEnabled = true


    private var cancellables = Set<AnyCancellable>()

    // MARK: - Configuration
    private let preparationSeconds = 3
    private let phases: [BreathingPhase] = [.inhale, .holdIn, .exhale, .holdOut]

    // MARK: - Time / Engine
    private var sessionStartDate: Date?
    private var phaseStartDate: Date?
    private var phaseIndex = 0

    // MARK: - Timers
    private var phaseTimer: Timer?
    private var secondTimer: Timer?

    // MARK: - Audio
    private var audioPlayer: AVAudioPlayer?
    private var cuePlayer: AVAudioPlayer?

    // MARK: - Live Activity
    private var liveActivityController = BreathingLiveActivityController()
    private var hasStartedLiveActivity = false


    // MARK: - Haptics
    private let haptics = DefaultBreathingHaptics()
//    private var liveActivityTimer: Timer?

    // MARK: - Dependencies
    private let libraryVM: LibraryViewModel
    private let sceneSettingsVM: SceneSettingsViewModel
    private let progressStore: ProgressStore

    var totalCycles: Int {
        libraryVM.cycleCount
    }

    // MARK: - Init
    init(
        libraryViewModel: LibraryViewModel,
        sceneSettingsViewModel: SceneSettingsViewModel,
        progressStore: ProgressStore

    ) {
        self.libraryVM = libraryViewModel
        self.sceneSettingsVM = sceneSettingsViewModel
        self.progressStore = progressStore

        self.isResting = UserDefaults.standard.bool(
            forKey: RestKeys.isResting
        )
    }

    // MARK: - Scene Binding
    private func bindSceneChanges() {
        sceneSettingsVM.$selectedScene
            .dropFirst()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.isPlaying && !self.isMuted {
                    self.stopAudio()
                    self.startAudio()
                }
            }
            .store(in: &cancellables)
    }

    var currentScene: BreathingScene {
        sceneSettingsVM.selectedScene
    }

    // MARK: - Configuration Observing
    private func bindConfigurationChanges() {
        libraryVM.$settings
            .dropFirst()
            .sink { [weak self] _ in
                self?.handleConfigurationChange()
            }
            .store(in: &cancellables)

        libraryVM.$cycleCount
            .dropFirst()
            .sink { [weak self] _ in
                self?.handleConfigurationChange()
            }
            .store(in: &cancellables)
    }

    private func handleConfigurationChange() {
        guard isPlaying || uiState != .idle else { return }
        stop()
    }

    // MARK: - Public Controls
//    func play() {
//        guard !isPlaying else { return }
//
//        isPlaying = true
//        isPaused = false
//        
//        sessionStartDate = Date()
//
//        let totalBreathingDuration =
//            Double(libraryVM.cycleCount) *
//            (libraryVM.settings.inhale +
//             libraryVM.settings.holdIn +
//             libraryVM.settings.exhale +
//             libraryVM.settings.holdOut)
//
//        let totalSessionDuration = totalBreathingDuration + Double(preparationSeconds)
//        let sessionEnd = sessionStartDate!.addingTimeInterval(totalSessionDuration)
//        
//        if !hasStartedLiveActivity {
//            liveActivityController.start(
//                totalCycles: totalCycles,
//                sessionStart: sessionStartDate!,
//                sessionEnd: sessionEnd
//            )
//            hasStartedLiveActivity = true
//        }
//
//        uiState = .preparing(seconds: preparationSeconds)
//        startPreparationCountdown()
//        setScreenAwake(true)
//        isResting = false
//    }
    
    func play() {
        guard !isPlaying else { return }

        isPlaying = true
        isPaused = false

        sessionStartDate = Date()

        let totalBreathingDuration =
            Double(libraryVM.cycleCount) *
            (libraryVM.settings.inhale +
             libraryVM.settings.holdIn +
             libraryVM.settings.exhale +
             libraryVM.settings.holdOut)

        let totalSessionDuration =
            Int(totalBreathingDuration) + preparationSeconds

        // ✅ ADD: initialize countdown ONCE
        remainingSessionSeconds = totalSessionDuration
        startSessionCountdown()

        let sessionEnd = sessionStartDate!.addingTimeInterval(
            Double(totalSessionDuration)
        )

        if !hasStartedLiveActivity {
            liveActivityController.start(
                totalCycles: totalCycles,
                sessionStart: sessionStartDate!,
                sessionEnd: sessionEnd
            )
            hasStartedLiveActivity = true
        }

        uiState = .preparing(seconds: preparationSeconds)
        startPreparationCountdown()
        setScreenAwake(true)
        isResting = false
    }


    func stop() {
        if hasStartedLiveActivity {
            liveActivityController.end()
            hasStartedLiveActivity = false
        }
        invalidateTimers()
        stopSessionCountdown()
        stopAudio()
        haptics.stop()

        currentPhase = nil
        phaseProgress = 0
        remainingSeconds = 0
        currentCycle = 0
        isPlaying = false
        isPaused = false
        isResting = true
        uiState = .idle
        setScreenAwake(false)
    }

    func pause() {
        guard isPlaying, !isPaused else { return }
        isPaused = true
        isResting = true
        haptics.stop()
        invalidateTimers()
        stopSessionCountdown()
        audioPlayer?.pause()
        setScreenAwake(false)
    }

    func resume() {
        guard isPlaying, isPaused else { return }
        isPaused = false
        isResting = false
        startSessionCountdown()
        
        if let duration = Optional(phaseDuration) {
            phaseStartDate = Date()
                .addingTimeInterval(-phaseProgress * duration)
        }
        
        resumeCurrentPhase()

        if !isMuted {
            audioPlayer?.play()
        }
//        if uiState == .breathing, let phase = currentPhase {
//            haptics.play(for: phase)
//        }
        if isHapticsEnabled,
           uiState == .breathing,
           let phase = currentPhase {
            haptics.play(for: phase)
        }
        setScreenAwake(true)
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
//    private func startPreparationCountdown() {
//        remainingSeconds = preparationSeconds
//        invalidateTimers()

//        secondTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//            guard let self else { return }
//
//            if self.remainingSeconds <= 1 {
//                timer.invalidate()
//                self.startBreathingSession()
//            } else {
//                self.remainingSeconds -= 1
//                self.uiState = .preparing(seconds: self.remainingSeconds)
//            }
        
    private func startPreparationCountdown() {
        remainingSeconds = preparationSeconds
        invalidateTimers()

        if isHapticsEnabled {
            haptics.playPreparationTick()
        }

        secondTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { return }

            if self.remainingSeconds <= 1 {
                timer.invalidate()
                self.startBreathingSession()
            } else {
                self.remainingSeconds -= 1
                self.uiState = .preparing(seconds: self.remainingSeconds)

                if self.isHapticsEnabled {
                    self.haptics.playPreparationTick()
                }
            }
        }
    }


    // MARK: - Breathing Session
    private func startBreathingSession() {
        uiState = .breathing

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
        setPhase(phase)
        
        phaseDuration = durationForPhase(phase)
        remainingSeconds = Int(phaseDuration)
        phaseProgress = 0
        phaseStartDate = Date()

        
        playCue(for: phase)
        invalidateTimers()
        
        phaseTimer = Timer.scheduledTimer(
            withTimeInterval: phaseDuration,
            repeats: false
        ) { [weak self] _ in
            guard let self else { return }
            self.phaseIndex += 1
            self.startPhase()
        }
        
        secondTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self,
                  let start = self.phaseStartDate else { return }

            let elapsed = Date().timeIntervalSince(start)
            self.phaseProgress = min(elapsed / self.phaseDuration, 1.0)

            if self.remainingSeconds > 0 {
                self.remainingSeconds = Int(self.phaseDuration - elapsed)
            }
        }
    }

    private func pauseForBackground() {
        guard isPlaying, !isPaused else { return }

        isPaused = true
        haptics.stop()
        invalidateTimers()
        audioPlayer?.pause()
        setScreenAwake(false)
    }

    
    private func resumeCurrentPhase() {
//        guard let start = phaseStartDate else { return }

        invalidateTimers()
        
        let remainingDuration = phaseDuration * (1.0 - phaseProgress)

        phaseTimer = Timer.scheduledTimer(
            withTimeInterval: remainingDuration,
            repeats: false
        ) { [weak self] _ in
            guard let self else { return }
            self.phaseIndex += 1
            self.startPhase()
        }

        secondTimer = Timer.scheduledTimer(
            withTimeInterval: 0.05,
            repeats: true
        ) { [weak self] _ in
            guard let self,
            let start = self.phaseStartDate else { return }
            
            let elapsed = Date().timeIntervalSince(start)
            self.phaseProgress = min(elapsed / self.phaseDuration, 1.0)

        }
    }


    // MARK: - Completion
    private func finishSession() {
        if hasStartedLiveActivity {
            liveActivityController.end()
            hasStartedLiveActivity = false
        }
        invalidateTimers()
        stopSessionCountdown()
        stopAudio()
        haptics.stop()
        currentPhase = nil
        phaseProgress = 0
        isPlaying = false
        isPaused = false
        uiState = .completed

        isResting = false
        scheduleRestReset()

        setScreenAwake(false)
        // ✅ NEW: persist completion
        
        let didEarnBadge = progressStore.completeSession()

        if didEarnBadge {
            showBadgePopup = true
        }
        print("🫁 Player uses ProgressStore:", ObjectIdentifier(progressStore))
    }

    // MARK: - Phase Helpers
    private func setPhase(_ newPhase: BreathingPhase) {
        guard currentPhase != newPhase else { return }
        currentPhase = newPhase

        if isHapticsEnabled {
            haptics.play(for: newPhase)
        }
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

    private func invalidateTimers() {
        phaseTimer?.invalidate()
        secondTimer?.invalidate()

        phaseTimer = nil
        secondTimer = nil
    }

    // MARK: - Audio
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    private func startAudio() {
        guard !isMuted else { return }

        guard let url = Bundle.main.url(
            forResource: currentScene.soundName,
            withExtension: "mp3"
        ) else { return }

        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.numberOfLoops = -1
        audioPlayer?.play()
    }

    private func playCue(for phase: BreathingPhase) {
        guard !isMuted else { return }

        guard let name = cueSoundName(for: phase),
              let url = Bundle.main.url(forResource: name, withExtension: "mpeg")
        else { return }

        cuePlayer = try? AVAudioPlayer(contentsOf: url)
        cuePlayer?.play()
    }

    private func cueSoundName(for phase: BreathingPhase) -> String? {
        switch phase {
        case .inhale: return "inhale"
        case .exhale: return "exhale"
        case .holdIn, .holdOut: return "hold"
        }
    }

    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    var isPreparing: Bool {
        if case .preparing = uiState {
            return true
        }
        return false
    }
    func toggleHaptics() {
        isHapticsEnabled.toggle()
    }
    private func setScreenAwake(_ enabled: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = enabled
            print("screen awake turned \(enabled ? "on" : "off")")
        }
    }
    func pauseIfNeeded() {
        guard isPlaying, !isPaused else { return }
        pause()
    }
    
    private func scheduleRestReset() {
        restResetWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.isResting = true
        }

        restResetWorkItem = workItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 3600,
            execute: workItem
        )
    }
    func start() {
        configureAudioSession()
        bindConfigurationChanges()
        bindSceneChanges()

        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.pauseForBackground()
        }
    }

    func teardown() {
        invalidateTimers()
        stopAudio()
        haptics.stop()
        liveActivityController.end()
        setScreenAwake(false)
    }

    
    private var isBreathingOrPreparing: Bool {
        switch uiState {
        case .breathing, .preparing:
            return true
        default:
            return false
        }
    }
    private func startSessionCountdown() {
        sessionTimer?.invalidate()

        sessionTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }

            guard self.remainingSessionSeconds > 0 else {
                self.sessionTimer?.invalidate()
                self.sessionTimer = nil
                return
            }

            self.remainingSessionSeconds -= 1
        }
    }
    private func stopSessionCountdown() {
        sessionTimer?.invalidate()
        sessionTimer = nil
    }


    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
