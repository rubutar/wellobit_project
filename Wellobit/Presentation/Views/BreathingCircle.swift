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
        Circle()
            .fill(Color.blue.opacity(0.35))
            .frame(width: 260, height: 260)
            .scaleEffect(scale)
            .onChange(of: phase) { newPhase in
                handlePhaseChange(newPhase)
            }
    }

    // MARK: - Phase logic (THIS IS THE KEY)
    private func handlePhaseChange(_ phase: BreathingPhase?) {
        guard let phase else {
            scale = 0.4
            return
        }

        switch phase {

        case .inhale:
            // Smooth expand
            withAnimation(.easeInOut(duration: duration)) {
                scale = 1.0
            }

        case .holdIn:
            // Stop animation, keep large
            withAnimation(.none) {
                scale = 1.0
            }

        case .exhale:
            // Smooth shrink
            withAnimation(.easeInOut(duration: duration)) {
                scale = 0.4
            }

        case .holdOut:
            // Stop animation, keep small
            withAnimation(.none) {
                scale = 0.4
            }
        }
    }
}
