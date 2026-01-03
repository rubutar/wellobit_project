//
//  ExtensionDelegate.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/12/25.
//

import WatchKit
import HealthKit


final class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    // Data layer
    private let healthManager = WatchHealthManager()
    
    // Domain layer
    private lazy var startUseCase: StartWatchWorkoutUseCaseProtocol =
        StartWatchWorkoutUseCase(healthManager: healthManager)
    
    private lazy var stopUseCase: StopWatchWorkoutUseCaseProtocol =
        StopWatchWorkoutUseCase(healthManager: healthManager)
    
    // Presentation layer
    lazy var workoutViewModel = WatchWorkoutViewModel(
        startUseCase: startUseCase,
        stopUseCase: stopUseCase,
        healthManager: healthManager
    )
    
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        print("Workout config received in ExtensionDelegate")
        workoutViewModel.handleIncoming(configuration: workoutConfiguration)
    }
}
