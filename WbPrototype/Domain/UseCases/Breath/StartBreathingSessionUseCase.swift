//
//  WorkoutSessionUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/12/25.
//

import Foundation

protocol StartBreathingSessionUseCaseProtocol {
    func execute() async
}

final class StartBreathingSessionUseCase: StartBreathingSessionUseCaseProtocol {
    private let phoneHealthManager: PhoneHealthManaging
    
    init(phoneHealthManager: PhoneHealthManaging) {
        self.phoneHealthManager = phoneHealthManager
    }
    
    func execute() async {
        do {
            try await phoneHealthManager.startWorkout()
        } catch {
            print("Failed to start breathing session: \(error)")
        }
    }
}


