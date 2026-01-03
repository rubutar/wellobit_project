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
    @Published var isWorkoutRunning = false
    
    private let startUseCase: StartWatchWorkoutUseCaseProtocol
    private let stopUseCase: StopWatchWorkoutUseCaseProtocol
    private let healthManager: WatchHealthManaging
    
    init(
        startUseCase: StartWatchWorkoutUseCaseProtocol,
        stopUseCase: StopWatchWorkoutUseCaseProtocol,
        healthManager: WatchHealthManaging
    ) {
        self.startUseCase = startUseCase
        self.stopUseCase = stopUseCase
        self.healthManager = healthManager
    }
    
    func requestAuthorization() {
        healthManager.requestAuthorization()
    }
    
    func handleIncoming(configuration: HKWorkoutConfiguration) {
        // called from ExtensionDelegate.handle(_:)
        startWorkout(with: configuration)
    }
    
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
}
