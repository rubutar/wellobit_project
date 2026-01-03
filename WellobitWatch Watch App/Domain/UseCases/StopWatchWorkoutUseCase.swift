
//
//  StartWatchWorkoutSessionUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/12/25.
//

protocol StopWatchWorkoutUseCaseProtocol {
    func execute()
}

final class StopWatchWorkoutUseCase: StopWatchWorkoutUseCaseProtocol {
    private let healthManager: WatchHealthManaging
    
    init(healthManager: WatchHealthManaging) {
        self.healthManager = healthManager
    }
    
    func execute() {
        healthManager.stopWorkoutSession()
    }
}
