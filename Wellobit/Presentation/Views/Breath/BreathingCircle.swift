//
//  BreathingCircle.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import Foundation
import SwiftUI

//import SwiftUI
//
//struct BreathingCircle: View {
//
//    /// Current breathing phase
//    let phase: BreathingPhase?
//
//    /// Phase progress (0.0 → 1.0)
//    /// Controlled by the ViewModel timer
//    let progress: Double
//
//    // MARK: - Body
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
//    }
//
//    // MARK: - Scale calculation (NO animation)
//    private var scale: CGFloat {
//        guard let phase else { return 0.4 }
//
//        switch phase {
//
//        case .inhale:
//            return lerp(from: 0.4, to: 1.0, t: progress)
//
//        case .exhale:
//            return lerp(from: 1.0, to: 0.4, t: progress)
//
//        case .holdIn:
//            return 1.0
//
//        case .holdOut:
//            return 0.4
//        }
//    }
//
//    // MARK: - Linear interpolation
//    private func lerp(from: CGFloat, to: CGFloat, t: Double) -> CGFloat {
//        from + (to - from) * CGFloat(min(max(t, 0), 1))
//    }
//}


struct BreathingCircle: View {

    let phase: BreathingPhase?
    let progress: Double   // 0 → 1

    // MARK: - Constants
    private let smallSize: CGFloat = 140
    private let bigSize: CGFloat = 260
    private let ringWidth: CGFloat = 6

    var body: some View {
        ZStack {
            // Loader ring (only during hold phases)
            if isHoldPhase {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color("orangeCircle"),
                        style: StrokeStyle(
                            lineWidth: ringWidth,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(
                        width: loaderSize,
                        height: loaderSize
                    )
            }

            // Core breathing circle
            Circle()
                .fill(Color("playButtonColor"))
                .frame(
                    width: animatedSize,
                    height: animatedSize
                )
            
            // Big circle
            Circle()
                .fill(Color.white.opacity(0.45))
                .frame(
                    width: bigSize,
                    height: bigSize
                )

            // ✨ Soft diffusion
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(
                    width: animatedSize * 1.15,
                    height: animatedSize * 1.15
                )
                .blur(radius: 8)
        }
    }

    // MARK: - Derived values

    private var animatedSize: CGFloat {
        guard let phase else { return smallSize }

        switch phase {
        case .inhale:
            return lerp(from: smallSize, to: bigSize, t: progress)

        case .exhale:
            return lerp(from: bigSize, to: smallSize, t: progress)

        case .holdIn:
            return bigSize

        case .holdOut:
            return smallSize
        }
    }

    private var loaderSize: CGFloat {
        switch phase {
        case .holdIn:
            return bigSize + ringWidth * 2
        case .holdOut:
            return smallSize + ringWidth * 2
        default:
            return 0
        }
    }

    private var isHoldPhase: Bool {
        phase == .holdIn || phase == .holdOut
    }

    // MARK: - Linear interpolation
    private func lerp(from: CGFloat, to: CGFloat, t: Double) -> CGFloat {
        from + (to - from) * CGFloat(min(max(t, 0), 1))
    }
}

#Preview {
    let repo = LocalBreathingRepository()
    let initialSettings = repo.load()
    let libraryVM = LibraryViewModel(
        repository: repo,
        initial: initialSettings
    )
    LibraryView(viewModel: libraryVM)
}
