//
//  BreathingCircle.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import SwiftUI

struct BreathingCircle: View {

    /// Current breathing phase
    let phase: BreathingPhase?

    /// Phase progress (0.0 → 1.0)
    /// Controlled by the ViewModel timer
    let progress: Double

    // MARK: - Body
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
    }

    // MARK: - Scale calculation (NO animation)
    private var scale: CGFloat {
        guard let phase else { return 0.4 }

        switch phase {

        case .inhale:
            return lerp(from: 0.4, to: 1.0, t: progress)

        case .exhale:
            return lerp(from: 1.0, to: 0.4, t: progress)

        case .holdIn:
            return 1.0

        case .holdOut:
            return 0.4
        }
    }

    // MARK: - Linear interpolation
    private func lerp(from: CGFloat, to: CGFloat, t: Double) -> CGFloat {
        from + (to - from) * CGFloat(min(max(t, 0), 1))
    }
}
