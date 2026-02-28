//
//  StretchSessionViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/02/26.
//

import Foundation
import Combine



@MainActor
final class StretchSessionViewModel: ObservableObject {
    
    let routine: StretchRoutine
    let customizedDurations: [String: Int]
    
    @Published var currentStepIndex: Int = 0
    @Published var remainingTime: Int = 0
    @Published var isRunning: Bool = false
    @Published var isCompleted: Bool = false
    @Published var totalDuration: Int = 0
    @Published var isPreparing: Bool = false
    @Published var preparationTime: Int = 5
    
    
    private var timer: Timer?
    
    var currentStep: StretchStep? {
        routine.steps.indices.contains(currentStepIndex)
        ? routine.steps[currentStepIndex]
        : nil
    }
    
    init(routine: StretchRoutine,
         customizedDurations: [String: Int]) {
        
        self.routine = routine
        self.customizedDurations = customizedDurations
        calculateTotalDuration()
        setupStep()
    }
    
    private func setupStep() {
        guard let step = currentStep else { return }
        remainingTime =
        customizedDurations[step.id] ?? step.defaultDuration
    }
    // MARK: - Session Control

    func pauseSession() {
        timer?.invalidate()
        isRunning = false
    }

    func resumeSession() {
        guard !isPreparing else { return }
        startTimer()
    }

    func nextStep() {
        if currentStepIndex < routine.steps.count - 1 {
            currentStepIndex += 1
            setupStep()
        } else {
            completeSession()
        }
    }

    func previousStep() {
        guard currentStepIndex > 0 else { return }
        currentStepIndex -= 1
        setupStep()
    }
    private func startTimer() {
        timer?.invalidate()
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.nextStep()
            }
        }
    }

    private func completeSession() {
        pauseSession()
        isCompleted = true
    }
    private func calculateTotalDuration() {
        totalDuration = routine.steps.reduce(0) { partialResult, step in
            let duration = customizedDurations[step.id] ?? step.defaultDuration
            return partialResult + duration
        }
    }
    
    func startSession() {
        startPreparationCountdown()
    }
    
    private func startPreparationCountdown() {
        timer?.invalidate()
        
        isPreparing = true
        isRunning = false
        preparationTime = 5
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            if self.preparationTime > 0 {
                self.preparationTime -= 1
            } else {
                self.timer?.invalidate()
                self.isPreparing = false
                self.startTimer()
            }
        }
    }
}
