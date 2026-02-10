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
    @State private var showCenterPause = false
    @State private var hidePauseWorkItem: DispatchWorkItem?




    var body: some View {
        VStack {
            topText
                .frame(height: 10)

            breathingCore

            bottomText
                .frame(height: 10)
        }
        .animation(.easeInOut, value: viewModel.uiState)
        .onReceive(
            NotificationCenter.default.publisher(for: .showCenterPauseButton)
        ) { _ in
            guard viewModel.isPlaying, !viewModel.isPaused else { return }

            withAnimation {
                showCenterPause = true
            }
        }

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
        VStack(spacing: 24) {

            ZStack {
                BreathingCircle(
                    phase: viewModel.currentPhase,
                    progress: viewModel.phaseProgress
                )
                .opacity(viewModel.uiState == .breathing ? 1 : 0)

//                if !viewModel.isPlaying {
//                    Button {
//                        handleMainButtonTap()
//                        viewModel.play()
//                    } label: {
//                        ZStack {
//                            Circle()
//                                .fill(Color("playButtonColor"))
//                                .frame(width: 120, height: 120)
//
//                            Image(systemName: "play.fill")
//                                .font(.system(size: 36))
//                                .foregroundColor(.white)
//                        }
//                    }
//                    .transition(.scale)
//                }
                if shouldShowMainButton {
                    Button {
                        handleMainAction()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color("playButtonColor"))
                                .frame(width: 120, height: 120)

                            Image(systemName: mainButtonIcon)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .transition(.scale)
                }


                if viewModel.uiState == .breathing {
                    VStack {
                        Spacer()

                        Text(centerPhaseText)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .frame(width: 200, height: 200)
                    .allowsHitTesting(false)
                }
            }
            .frame(width: 260, height: 260)

            if viewModel.uiState == .breathing {
                Text(formatTime(viewModel.remainingSessionSeconds))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .monospacedDigit()
                    .transition(.opacity)
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .showCenterPauseButton)
        ) { _ in
            guard viewModel.isPlaying, !viewModel.isPaused else { return }
            showPauseThenAutoHide()
        }

        .onTapGesture {
            guard viewModel.isPlaying, !viewModel.isPaused else { return }

            // First tap: reveal pause button
            withAnimation {
                showCenterPause = true
            }

            NotificationCenter.default.post(
                name: .showBreathingControls,
                object: nil
            )
        }

        .onChange(of: viewModel.isPlaying) { playing in
            if playing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showCenterPause = false
                    }
                }
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
//        viewModel.showPreSessionModal = true
    }
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    private func handleMainButtonTapIfNeeded() {
        // Only send to Watch / pre-session once
        if !viewModel.isPlaying {
            WatchSessionManager.shared.sendPreSession(
                cycles: libraryViewModel.cycleCount,
                totalSeconds: libraryViewModel.totalDurationSeconds
            )
        }
    }


    private var shouldShowMainButton: Bool {
        if !viewModel.isPlaying { return true }   // Play
        if viewModel.isPaused { return true }     // Resume
        return showCenterPause                    // Pause (auto-hide)
    }



    private var mainButtonIcon: String {
        if !viewModel.isPlaying {
            return "play.fill"
        }

        if viewModel.isPaused {
            return "play.fill"
        }

        return "pause.fill"
    }

    
    private func handleMainAction() {
        hidePauseWorkItem?.cancel()

        if !viewModel.isPlaying {
            handleMainButtonTapIfNeeded()
            viewModel.play()
        } else if viewModel.isPaused {
            viewModel.resume()
        } else {
            viewModel.pause()
        }

        showCenterPause = false
    }

    private func showPauseThenAutoHide() {
        hidePauseWorkItem?.cancel()
        showCenterPause = true

        let workItem = DispatchWorkItem {
            withAnimation {
                showCenterPause = false
            }
        }

        hidePauseWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem)
    }


}

