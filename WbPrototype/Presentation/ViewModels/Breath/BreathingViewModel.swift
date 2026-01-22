//
//  WorkoutSessionViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/12/25.
//

import Combine

@MainActor
final class BreathingViewModel: ObservableObject {
    @Published var isBreathing = false
    
    private let startBreathingUseCase: StartBreathingSessionUseCaseProtocol
    
    init(startBreathingUseCase: StartBreathingSessionUseCaseProtocol) {
        self.startBreathingUseCase = startBreathingUseCase
    }

    func startButtonTapped() {
        guard !isBreathing else { return }
        isBreathing = true
        Task {
            await startBreathingUseCase.execute()
        }
    }
    
    func stopButtonTapped() {
        isBreathing = false
    }
}
