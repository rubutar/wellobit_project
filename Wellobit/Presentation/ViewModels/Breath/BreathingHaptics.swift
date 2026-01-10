//
//  BreathingHaptics.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 08/01/26.
//

import UIKit

protocol BreathingHaptics {
    func play(for phase: BreathingPhase)
}

import UIKit

final class DefaultBreathingHaptics: BreathingHaptics {

    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()

    init() {
        softImpact.prepare()
        rigidImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notification.prepare()
    }

    func play(for phase: BreathingPhase) {
        switch phase {

        case .inhale:
            notification.notificationOccurred(.error)

        case .holdIn:
            // Stable intentional pause
            heavyImpact.impactOccurred(intensity: 1)


        case .exhale:
            notification.notificationOccurred(.success)

        case .holdOut:
            heavyImpact.impactOccurred(intensity: 1)
        }
    }
}

