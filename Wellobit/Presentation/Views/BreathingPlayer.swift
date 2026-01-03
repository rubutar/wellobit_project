//
//  BreathingPlayer.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//


import SwiftUI

struct BreathingPlayer: View {
    @StateObject private var viewModel: BreathingPlayerViewModel
    

    init(libraryViewModel: LibraryViewModel) {
        _viewModel = StateObject(
            wrappedValue: BreathingPlayerViewModel(
                libraryViewModel: libraryViewModel
            )
        )
    }

    var body: some View {
        VStack() {
            ZStack() {
                // 🔵 BREATHING ANIMATION
                BreathingCircle(
                    phase: viewModel.currentPhase,
                    duration: viewModel.phaseDuration
                )
                
                // Play / Stop
                Button {
                    viewModel.isPlaying ? viewModel.stop() : viewModel.play()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: viewModel.isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                }
            }
            // Phase label
            Text(phaseLabel)
                .font(.title2.bold())
                .foregroundColor(.white)
        }
    }
    
    private var phaseLabel: String {
        guard let phase = viewModel.currentPhase else { return "" }
        return "Cycle \(viewModel.currentCycle)/\(viewModel.totalCycles) · \(phase.rawValue.capitalized) (\(viewModel.remainingSeconds))"
    }
}
