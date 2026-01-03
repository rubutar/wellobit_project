//
//  StartWatchWorkoutSessionUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/12/25.
//

import HealthKit

protocol StartWatchWorkoutUseCaseProtocol {
    func execute(with configuration: HKWorkoutConfiguration)
}

final class StartWatchWorkoutUseCase: StartWatchWorkoutUseCaseProtocol {
    private let healthManager: WatchHealthManaging
    
    init(healthManager: WatchHealthManaging) {
        self.healthManager = healthManager
    }
    
    func execute(with configuration: HKWorkoutConfiguration) {
        healthManager.startWorkoutSession(with: configuration)
    }
}
