//
//  BreathingPlayer.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import SwiftUI

struct BreathingPlayer: View {

    @ObservedObject var viewModel: BreathingPlayerViewModel
    @ObservedObject var libraryViewModel: LibraryViewModel

    var body: some View {
        VStack() {
            topText
                .frame(height: 10)

            breathingCore

            bottomText
                .frame(height: 10)
        }
        .overlay(alignment: .bottomTrailing) {
            controlButtons
        }
        .animation(.easeInOut, value: viewModel.uiState)
    }
}

// MARK: - Subviews
private extension BreathingPlayer {

    // 🔝 Top text
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

            case .breathing:
                Text("\(viewModel.currentCycle)/\(viewModel.totalCycles)")
                    .font(.title2.bold())
                    .foregroundColor(.white)

            default:
                Color.clear
            }
        }
    }

    // Breathing core (center button fixed)
    var breathingCore: some View {
        ZStack {
            
            BreathingCircle(
                phase: viewModel.currentPhase,
                progress: viewModel.phaseProgress
            )
            .opacity(viewModel.uiState == .breathing ? 1 : 0)
            
            if !viewModel.isPreparing {
                Button {
                    handleMainButtonTap()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: buttonIcon)
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    // Bottom phase text
    var bottomText: some View {
        Text(phaseLabel)
            .font(.title2.bold())
            .foregroundColor(.white)
            .opacity(viewModel.uiState == .breathing ? 1 : 0)
    }

    //  Floating controls (DO NOT affect layout)
    var controlButtons: some View {
        VStack(spacing: 12) {

            Button {
                viewModel.toggleMute()
            } label: {
                Image(systemName: viewModel.isMuted
                      ? "speaker.slash.fill"
                      : "speaker.wave.2.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }

            Button {
                viewModel.stop()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 80)
        .opacity(viewModel.isPlaying ? 1 : 0)
        .allowsHitTesting(viewModel.isPlaying)
    }


    // MARK: - Helpers
    func handleMainButtonTap() {
        if !viewModel.isPlaying {
//            viewModel.play()
            WatchSessionManager.shared.sendPreSession(
                cycles: libraryViewModel.cycleCount,
                totalSeconds: libraryViewModel.totalDurationSeconds
            )
            viewModel.showPreSessionModal = true
        } else if viewModel.isPaused {
            viewModel.resume()
        } else {
            viewModel.pause()
        }
    }

    var phaseLabel: String {
        guard let phase = viewModel.currentPhase else { return "" }
        return "\(phase.rawValue.capitalized) (\(viewModel.remainingSeconds))"
    }

    var buttonIcon: String {
        if !viewModel.isPlaying {
            return "play.fill"
        } else if viewModel.isPaused {
            return "play.fill"
        } else {
            return "pause.fill"
        }
    }
}



#Preview {
    let breathingRepo = LocalBreathingRepository()
    let initialSettings = breathingRepo.load()

    let libraryVM = LibraryViewModel(
        repository: breathingRepo,
        initial: initialSettings
    )

    let sceneVM = SceneSettingsViewModel(
        repository: LocalBreathingSceneRepository()
    )

    let playerVM = BreathingPlayerViewModel(
        libraryViewModel: libraryVM,
        sceneSettingsViewModel: sceneVM
    )

    BreathingPlayer(viewModel: playerVM, libraryViewModel: libraryVM)
        .preferredColorScheme(.dark)
        .background(Color.white)
}
