//
//  BreathingCircle.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

//import SwiftUI
//
//struct BreathingCircle: View {
//
//    let phase: BreathingPhase?
//    let duration: TimeInterval
//
//    @State private var scale: CGFloat = 0.4
//
//    var body: some View {
//        ZStack {
//
//            // Outer soft ring
//            Circle()
//                .fill(Color.blue.opacity(0.12))
//                .frame(width: 340, height: 340)
//                .scaleEffect(scale * 1.05)
//                .blur(radius: 8)
//
//            // Middle diffusion layer
//            Circle()
//                .fill(Color.blue.opacity(0.20))
//                .frame(width: 300, height: 300)
//                .scaleEffect(scale)
//                .blur(radius: 4)
//
//            // Core circle
//            Circle()
//                .fill(Color.blue.opacity(0.35))
//                .frame(width: 260, height: 260)
//                .scaleEffect(scale)
//        }
//        .onChange(of: phase) { newPhase in
//            animate(for: newPhase)
//        }
//    }
//
//    // MARK: - Breathing animation
//    private func animate(for phase: BreathingPhase?) {
//        guard let phase else {
//            scale = 0.4
//            return
//        }
//
//        let adjustedDuration = duration * 1.3
//
//        switch phase {
//
//        case .inhale:
//            withAnimation(
//                .timingCurve(0.2, 0.0, 0.1, 1.0, duration: adjustedDuration)
//            ) {
//                scale = 1.0
//            }
//
//        case .exhale:
//            withAnimation(
//                .timingCurve(0.2, 0.0, 0.1, 1.0, duration: adjustedDuration)
//            ) {
//                scale = 0.4
//            }
//
//        case .holdIn:
//            withAnimation(.linear(duration: 0.4)) {
//                scale = 1.0
//            }
//
//        case .holdOut:
//            withAnimation(.linear(duration: 0.4)) {
//                scale = 0.4
//            }
//        }
//    }
//}

//
//import SwiftUI
//
//struct BreathingCircle: View {
//
//    let phase: BreathingPhase?
//    let duration: TimeInterval
//    let isPaused: Bool
//
//    private var targetScale: CGFloat {
//        switch phase {
//        case .inhale, .holdIn:
//            return 1.0
//        case .exhale, .holdOut:
//            return 0.4
//        case .none:
//            return 0.4
//        }
//    }
//
//    var body: some View {
//        ZStack {
//
//            Circle()
//                .fill(Color.blue.opacity(0.12))
//                .frame(width: 340, height: 340)
//                .scaleEffect(targetScale * 1.05)
//                .blur(radius: 8)
//
//            Circle()
//                .fill(Color.blue.opacity(0.20))
//                .frame(width: 300, height: 300)
//                .scaleEffect(targetScale)
//                .blur(radius: 4)
//
//            Circle()
//                .fill(Color.blue.opacity(0.35))
//                .frame(width: 260, height: 260)
//                .scaleEffect(targetScale)
//        }
//        .animation(
//            isPaused
//                ? nil
//                : animation(for: phase),
//            value: targetScale
//        )
//    }
//
//    // MARK: - Animation definition
//    private func animation(for phase: BreathingPhase?) -> Animation? {
//        guard let phase else { return nil }
//
//        switch phase {
//        case .inhale, .exhale:
//            return .timingCurve(
//                0.2, 0.0, 0.1, 1.0,
//                duration: duration * 1.3
//            )
//
//        case .holdIn, .holdOut:
//            return .linear(duration: 0.4)
//        }
//    }
//}



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
