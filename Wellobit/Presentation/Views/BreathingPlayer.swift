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
        VStack {
            switch viewModel.uiState {

            case .idle:
                idleView

            case .preparing(let seconds):
                preparingView(seconds: seconds)

            case .breathing:
                breathingView

            case .completed:
                completedView
            }
        }
        .animation(.easeInOut, value: viewModel.uiState)
    }
}

// MARK: - Subviews
private extension BreathingPlayer {

    // ▶️ Idle
    var idleView: some View {
        VStack {
            Spacer()

            Button {
                viewModel.play()
            } label: {
                Image(systemName: "play.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .padding(40)
                    .background(Color.blue.opacity(0.3))
                    .clipShape(Circle())
            }

            Spacer()
        }
    }

    // ⏳ Preparing
    func preparingView(seconds: Int) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Get Ready")
                .font(.title.bold())
                .foregroundColor(.white.opacity(0.8))

            Text("\(seconds)")
                .font(.system(size: 64, weight: .bold))
                .foregroundColor(.white)

            Spacer()
        }
    }

    // 🌬 Breathing (your original UI, unchanged)
    var breathingView: some View {
        VStack {

            Text("\(viewModel.currentCycle)/\(viewModel.totalCycles)")
                .font(.title2.bold())
                .foregroundColor(.white)

            ZStack {
                BreathingCircle(
                    phase: viewModel.currentPhase,
                    duration: viewModel.phaseDuration
                )

                Button {
                    if !viewModel.isPlaying {
                        viewModel.play()
                    } else if viewModel.isPaused {
                        viewModel.resume()
                    } else {
                        viewModel.pause()
                    }
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

            Text(phaseLabel)
                .font(.title2.bold())
                .foregroundColor(.white)

            // 🔇 Mute + ❌ Cancel (fixed position, no layout jump)
            VStack {
                HStack {
                    Spacer()

                    HStack(spacing: 12) {

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
                }

                Spacer()
            }
            .padding()
            .opacity(viewModel.isPlaying ? 1 : 0)
            .allowsHitTesting(viewModel.isPlaying)
        }
    }

    // 🎉 Completed
    var completedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Well done")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Button("Done") {
                viewModel.stop()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)

            Spacer()
        }
    }

    // MARK: - Helpers
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
