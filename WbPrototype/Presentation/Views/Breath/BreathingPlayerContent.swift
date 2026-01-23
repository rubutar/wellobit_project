//
//  BreathingPlayerContent.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 23/01/26.
//


import SwiftUI

struct BreathingPlayerContent: View {

    @ObservedObject var viewModel: BreathingPlayerViewModel
    @ObservedObject var libraryViewModel: LibraryViewModel

    var body: some View {
        VStack {
            topText
                .frame(height: 10)

            breathingCore

            bottomText
                .frame(height: 10)
        }
        .animation(.easeInOut, value: viewModel.uiState)
    }
}

private extension BreathingPlayerContent {

    var topText: some View {
        Group {
            switch viewModel.uiState {
            case .preparing(let seconds):
                VStack(spacing: 8) {
                    Text("Get Ready")
                        .font(.title.bold())
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(seconds)")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.white)
                }
            default:
                Color.clear
            }
        }
    }

    var breathingCore: some View {
        ZStack {
            BreathingCircle(
                phase: viewModel.currentPhase,
                progress: viewModel.phaseProgress
            )
            .opacity(viewModel.uiState == .breathing ? 1 : 0)

            if !viewModel.isPlaying {
                Button {
                    handleMainButtonTap()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color("playButtonColor"))
                            .frame(width: 120, height: 120)

                        Image(systemName: "play.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                }
                .transition(.scale)
            }

            if viewModel.uiState == .breathing {
                Text(centerPhaseText)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }

    var bottomText: some View {
        Text("")
            .opacity(0)
    }

    var centerPhaseText: String {
        guard let phase = viewModel.currentPhase else { return "" }
        return phase == .exhale ? "Exhale" : phase == .inhale ? "Inhale" : "Hold"
    }

    func handleMainButtonTap() {
        WatchSessionManager.shared.sendPreSession(
            cycles: libraryViewModel.cycleCount,
            totalSeconds: libraryViewModel.totalDurationSeconds
        )
        viewModel.showPreSessionModal = true
    }
}
