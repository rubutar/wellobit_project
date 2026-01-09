//
//  WatchWorkoutViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/12/25.
//

import Foundation
import HealthKit
import Combine

@MainActor
final class WatchWorkoutViewModel: ObservableObject {

    // MARK: - Published UI State
    @Published var isWorkoutRunning = false

    // 🔔 Pre-session state (from iPhone)
    @Published var pendingCycles: Int?
    @Published var pendingTotalSeconds: Int?
    @Published var currentHRV: Int?


    // MARK: - Dependencies
    private let startUseCase: StartWatchWorkoutUseCaseProtocol
    private let stopUseCase: StopWatchWorkoutUseCaseProtocol
    private let healthManager: WatchHealthManaging

    // MARK: - Init
    init(
        startUseCase: StartWatchWorkoutUseCaseProtocol,
        stopUseCase: StopWatchWorkoutUseCaseProtocol,
        healthManager: WatchHealthManaging
    ) {
        self.startUseCase = startUseCase
        self.stopUseCase = stopUseCase
        self.healthManager = healthManager
    }

    // MARK: - Authorization
    func requestAuthorization() {
        healthManager.requestAuthorization()
    }

    // MARK: - Incoming from system / iPhone
    func handleIncoming(configuration: HKWorkoutConfiguration) {
        // Called from ExtensionDelegate / WCSession if needed
        startWorkout(with: configuration)
    }

    /// Called when iPhone sends a "breathing_pre_session" message
    func handlePreSession(
        cycles: Int,
        totalSeconds: Int
    ) {
        pendingCycles = cycles
        pendingTotalSeconds = totalSeconds
    }

    // MARK: - Workout Controls
    func startWorkout(with configuration: HKWorkoutConfiguration) {
        guard !isWorkoutRunning else { return }
        isWorkoutRunning = true
        startUseCase.execute(with: configuration)
    }

    func stopButtonTapped() {
        guard isWorkoutRunning else { return }
        isWorkoutRunning = false
        stopUseCase.execute()
    }

    // MARK: - Pre-session cleanup
    func clearPreSession() {
        pendingCycles = nil
        pendingTotalSeconds = nil
    }
}
