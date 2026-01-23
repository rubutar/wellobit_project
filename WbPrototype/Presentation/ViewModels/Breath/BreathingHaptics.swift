//
//  BreathingHaptics.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 08/01/26.
//

import UIKit

protocol BreathingHaptics {
    func play(for phase: BreathingPhase)
    func stop()
}

//final class DefaultBreathingHaptics: BreathingHaptics {
//
//    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
//    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
//    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
//    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
//    private let notification = UINotificationFeedbackGenerator()
//
//    init() {
//        softImpact.prepare()
//        rigidImpact.prepare()
//        mediumImpact.prepare()
//        heavyImpact.prepare()
//        notification.prepare()
//    }
//
//    func play(for phase: BreathingPhase) {
//        switch phase {
//
//        case .inhale:
//            notification.notificationOccurred(.error)
//
//        case .holdIn:
//            // Stable intentional pause
//            heavyImpact.impactOccurred(intensity: 1)
//
//
//        case .exhale:
//            notification.notificationOccurred(.success)
//
//        case .holdOut:
//            heavyImpact.impactOccurred(intensity: 1)
//        }
//    }
//}

import UIKit

@MainActor
final class DefaultBreathingHaptics: BreathingHaptics {

    private let impact = UIImpactFeedbackGenerator(style: .heavy)

    private var timer: Timer?
    private var startTime: Date?
    private var duration: TimeInterval = 0
    private var currentPhase: BreathingPhase?

    init() {
        impact.prepare()
    }

    func play(for phase: BreathingPhase) {
        stopPulsing()

        currentPhase = phase

        switch phase {

        case .inhale:
            startPulsing(duration: durationForPhase(phase), rampUp: true)

        case .exhale:
            startPulsing(duration: durationForPhase(phase), rampUp: false)

        case .holdIn, .holdOut:
            impact.impactOccurred(intensity: 1.0)
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        startTime = nil
    }

    // MARK: - Pulsing Logic

    private func startPulsing(duration: TimeInterval, rampUp: Bool) {
        let safeDuration = max(duration, 0.1)   // ✅ new local constant
        self.duration = safeDuration
        startTime = Date()

        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
            guard let self,
                  let start = self.startTime else { return }

            let elapsed = Date().timeIntervalSince(start)
            let progress = min(elapsed / safeDuration, 1.0)

            let intensity = rampUp ? progress : (1.0 - progress)
            let clamped = max(0.2, min(intensity, 1.0))

            self.impact.impactOccurred(intensity: clamped)

            if progress >= 1.0 {
                self.stopPulsing()
            }
        }
    }

    func playPreparationTick() {
        impact.impactOccurred(intensity: 1.0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            self.impact.impactOccurred(intensity: 1.0)
        }
    }



    private func stopPulsing() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Duration source (IMPORTANT)

    private func durationForPhase(_ phase: BreathingPhase) -> TimeInterval {

        switch phase {
        case .inhale: return 3
        case .exhale: return 3
        case .holdIn, .holdOut: return 0
        }
    }

    deinit {
        Task { @MainActor in
            self.stopPulsing()
        }    }
}
