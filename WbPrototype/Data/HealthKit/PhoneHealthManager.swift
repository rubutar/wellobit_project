//
//  PhoneHealthManager.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/12/25.
//

import Foundation
import HealthKit

protocol PhoneHealthManaging {
    func startWorkout() async throws
}

final class PhoneHealthManager: PhoneHealthManaging {
    private let healthStore = HKHealthStore()
    
    func startWorkout() async throws {
        let config = HKWorkoutConfiguration()
        config.activityType = .running
        config.locationType = .outdoor
        
        try await healthStore.startWatchApp(toHandle: config)
    }
}
