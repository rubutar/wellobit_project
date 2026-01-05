//
//  BreathingCircle.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import SwiftUI

struct BreathingCircle: View {

    let phase: BreathingPhase?
    let duration: TimeInterval

    @State private var scale: CGFloat = 0.4

    var body: some View {
        ZStack {

            // Outer soft ring
            Circle()
                .fill(Color.blue.opacity(0.12))
                .frame(width: 340, height: 340)
                .scaleEffect(scale * 1.05)
                .blur(radius: 8)

            // Middle diffusion layer
            Circle()
                .fill(Color.blue.opacity(0.20))
                .frame(width: 300, height: 300)
                .scaleEffect(scale)
                .blur(radius: 4)

            // Core circle
            Circle()
                .fill(Color.blue.opacity(0.35))
                .frame(width: 260, height: 260)
                .scaleEffect(scale)
        }
        .onChange(of: phase) { newPhase in
            animate(for: newPhase)
        }
    }

    // MARK: - Breathing animation
    private func animate(for phase: BreathingPhase?) {
        guard let phase else {
            scale = 0.4
            return
        }

        let adjustedDuration = duration * 1.3

        switch phase {

        case .inhale:
            withAnimation(
                .timingCurve(0.2, 0.0, 0.1, 1.0, duration: adjustedDuration)
            ) {
                scale = 1.0
            }

        case .exhale:
            withAnimation(
                .timingCurve(0.2, 0.0, 0.1, 1.0, duration: adjustedDuration)
            ) {
                scale = 0.4
            }

        case .holdIn:
            withAnimation(.linear(duration: 0.4)) {
                scale = 1.0
            }

        case .holdOut:
            withAnimation(.linear(duration: 0.4)) {
                scale = 0.4
            }
        }
    }
}
