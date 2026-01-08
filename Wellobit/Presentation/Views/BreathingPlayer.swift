//
//  BreathingPlayer.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//


//import SwiftUI
//
//struct BreathingPlayer: View {
//    @StateObject private var viewModel: BreathingPlayerViewModel
//
//    init(libraryViewModel: LibraryViewModel) {
//        _viewModel = StateObject(
//            wrappedValue: BreathingPlayerViewModel(
//                libraryViewModel: libraryViewModel
//            )
//        )
//    }
//
//    var body: some View {
//        VStack {
//            switch viewModel.uiState {
//
//            case .idle:
//                idleView
//
//            case .preparing(let seconds):
//                preparingView(seconds: seconds)
//
//            case .breathing:
//                breathingView
//
//            case .completed:
//                completedView
//            }
//        }
//        .animation(.easeInOut, value: viewModel.uiState)
//    }
//}
//
//// MARK: - Subviews
//private extension BreathingPlayer {
//
//    // ▶️ Idle
//    var idleView: some View {
//        VStack {
//            Spacer()
//
//            Button {
//                viewModel.play()
//            } label: {
//                Image(systemName: "play.fill")
//                    .font(.system(size: 40))
//                    .foregroundColor(.white)
//                    .padding(40)
//                    .background(Color.blue.opacity(0.3))
//                    .clipShape(Circle())
//            }
//
//            Spacer()
//        }
//    }
//
//    func preparingView(seconds: Int) -> some View {
//        VStack(spacing: 24) {
//            Spacer()
//
//            Text("Get Ready")
//                .font(.title.bold())
//                .foregroundColor(.white.opacity(0.8))
//
//            Text("\(seconds)")
//                .font(.system(size: 64, weight: .bold))
//                .foregroundColor(.white)
//
//            Spacer()
//        }
//    }
//
//    var breathingView: some View {
//        VStack {
//
//            Text("\(viewModel.currentCycle)/\(viewModel.totalCycles)")
//                .font(.title2.bold())
//                .foregroundColor(.white)
//
//            ZStack {
//                BreathingCircle(
//                    phase: viewModel.currentPhase,
//                    duration: viewModel.phaseDuration
//                )
//
//                Button {
//                    if !viewModel.isPlaying {
//                        viewModel.play()
//                    } else if viewModel.isPaused {
//                        viewModel.resume()
//                    } else {
//                        viewModel.pause()
//                    }
//                } label: {
//                    ZStack {
//                        Circle()
//                            .fill(Color.blue.opacity(0.3))
//                            .frame(width: 120, height: 120)
//
//                        Image(systemName: buttonIcon)
//                            .font(.system(size: 36))
//                            .foregroundColor(.white)
//                    }
//                }
//            }
//
//            Text(phaseLabel)
//                .font(.title2.bold())
//                .foregroundColor(.white)
//
//            VStack {
//                HStack {
//                    Spacer()
//
//                    HStack(spacing: 12) {
//
//                        Button {
//                            viewModel.toggleMute()
//                        } label: {
//                            Image(systemName: viewModel.isMuted
//                                  ? "speaker.slash.fill"
//                                  : "speaker.wave.2.fill")
//                                .foregroundColor(.white)
//                                .padding(10)
//                                .background(Color.black.opacity(0.4))
//                                .clipShape(Circle())
//                        }
//
//                        Button {
//                            viewModel.stop()
//                        } label: {
//                            Image(systemName: "xmark")
//                                .foregroundColor(.white)
//                                .padding(10)
//                                .background(Color.black.opacity(0.4))
//                                .clipShape(Circle())
//                        }
//                    }
//                }
//
//                Spacer()
//            }
//            .padding()
//            .opacity(viewModel.isPlaying ? 1 : 0)
//            .allowsHitTesting(viewModel.isPlaying)
//        }
//    }
//
//    var completedView: some View {
//        VStack(spacing: 24) {
//            Spacer()
//
//            Text("Well done")
//                .font(.largeTitle.bold())
//                .foregroundColor(.white)
//
//            Button("Done") {
//                viewModel.stop()
//            }
//            .font(.headline)
//            .foregroundColor(.white)
//            .padding(.horizontal, 24)
//            .padding(.vertical, 12)
//            .background(Color.white.opacity(0.2))
//            .cornerRadius(12)
//
//            Spacer()
//        }
//    }
//
//    // MARK: - Helpers
//    var phaseLabel: String {
//        guard let phase = viewModel.currentPhase else { return "" }
//        return "\(phase.rawValue.capitalized) (\(viewModel.remainingSeconds))"
//    }
//
//    var buttonIcon: String {
//        if !viewModel.isPlaying {
//            return "play.fill"
//        } else if viewModel.isPaused {
//            return "play.fill"
//        } else {
//            return "pause.fill"
//        }
//    }
//}


//import SwiftUI
//
//struct BreathingPlayer: View {
//
//    @ObservedObject var viewModel: BreathingPlayerViewModel
//
//    var body: some View {
//        VStack {
//            switch viewModel.uiState {
//
//            case .idle:
//                idleView
//
//            case .preparing(let seconds):
//                preparingView(seconds: seconds)
//
//            case .breathing:
//                breathingView
//
//            case .completed:
//                completedView
//            }
//        }
//        .animation(.easeInOut, value: viewModel.uiState)
//    }
//}
//
//// MARK: - Subviews
//private extension BreathingPlayer {
//
//    // ▶️ Idle
//    var idleView: some View {
//        VStack {
//            Spacer()
//
//            Button {
//                viewModel.play()
//            } label: {
//                Image(systemName: "play.fill")
//                    .font(.system(size: 40))
//                    .foregroundColor(.white)
//                    .padding(40)
//                    .background(Color.blue.opacity(0.3))
//                    .clipShape(Circle())
//            }
//
//            Spacer()
//        }
//    }
//
//    func preparingView(seconds: Int) -> some View {
//        VStack(spacing: 24) {
//            Spacer()
//
//            Text("Get Ready")
//                .font(.title.bold())
//                .foregroundColor(.white.opacity(0.8))
//
//            Text("\(seconds)")
//                .font(.system(size: 64, weight: .bold))
//                .foregroundColor(.white)
//
//            Spacer()
//        }
//    }
//
//    var breathingView: some View {
//        VStack {
//
//            Text("\(viewModel.currentCycle)/\(viewModel.totalCycles)")
//                .font(.title2.bold())
//                .foregroundColor(.white)
//
//            ZStack {
//                BreathingCircle(
//                    phase: viewModel.currentPhase,
//                    duration: viewModel.phaseDuration
//                )
//
//                Button {
//                    if !viewModel.isPlaying {
//                        viewModel.play()
//                    } else if viewModel.isPaused {
//                        viewModel.resume()
//                    } else {
//                        viewModel.pause()
//                    }
//                } label: {
//                    ZStack {
//                        Circle()
//                            .fill(Color.blue.opacity(0.3))
//                            .frame(width: 120, height: 120)
//
//                        Image(systemName: buttonIcon)
//                            .font(.system(size: 36))
//                            .foregroundColor(.white)
//                    }
//                }
//            }
//
//            Text(phaseLabel)
//                .font(.title2.bold())
//                .foregroundColor(.white)
//
//            VStack {
//                HStack {
//                    Spacer()
//
//                    HStack(spacing: 12) {
//
//                        Button {
//                            viewModel.toggleMute()
//                        } label: {
//                            Image(systemName: viewModel.isMuted
//                                  ? "speaker.slash.fill"
//                                  : "speaker.wave.2.fill")
//                                .foregroundColor(.white)
//                                .padding(10)
//                                .background(Color.black.opacity(0.4))
//                                .clipShape(Circle())
//                        }
//
//                        Button {
//                            viewModel.stop()
//                        } label: {
//                            Image(systemName: "xmark")
//                                .foregroundColor(.white)
//                                .padding(10)
//                                .background(Color.black.opacity(0.4))
//                                .clipShape(Circle())
//                        }
//                    }
//                }
//
//                Spacer()
//            }
//            .padding()
//            .opacity(viewModel.isPlaying ? 1 : 0)
//            .allowsHitTesting(viewModel.isPlaying)
//        }
//    }
//
//    var completedView: some View {
//        VStack(spacing: 24) {
//            Spacer()
//
//            Text("Well done")
//                .font(.largeTitle.bold())
//                .foregroundColor(.white)
//
//            Button("Done") {
//                viewModel.stop()
//            }
//            .font(.headline)
//            .foregroundColor(.white)
//            .padding(.horizontal, 24)
//            .padding(.vertical, 12)
//            .background(Color.white.opacity(0.2))
//            .cornerRadius(12)
//
//            Spacer()
//        }
//    }
//
//    // MARK: - Helpers
//    var phaseLabel: String {
//        guard let phase = viewModel.currentPhase else { return "" }
//        return "\(phase.rawValue.capitalized) (\(viewModel.remainingSeconds))"
//    }
//
//    var buttonIcon: String {
//        if !viewModel.isPlaying {
//            return "play.fill"
//        } else if viewModel.isPaused {
//            return "play.fill"
//        } else {
//            return "pause.fill"
//        }
//    }
//}


import SwiftUI

struct BreathingPlayer: View {

    @ObservedObject var viewModel: BreathingPlayerViewModel

    var body: some View {
        VStack(spacing: 24) {

            // MARK: - Top Text (reserved space)
            topText
                .frame(height: 50)

            // MARK: - Core Breathing Area (button NEVER moves)
            breathingCore

            // MARK: - Bottom Text (reserved space)
            bottomText
                .frame(height: 40)
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

    // 🎯 Breathing core (center button fixed)
    var breathingCore: some View {
        ZStack {

            BreathingCircle(
                phase: viewModel.currentPhase,
                duration: viewModel.phaseDuration
            )
            .opacity(viewModel.uiState == .breathing ? 1 : 0)

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

    // 🔽 Bottom phase text
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
        .padding(.bottom, 80) // 👈 lifts it up so it sits mid-right
        .opacity(viewModel.isPlaying ? 1 : 0)
        .allowsHitTesting(viewModel.isPlaying)
    }


    // MARK: - Helpers
    func handleMainButtonTap() {
        if !viewModel.isPlaying {
            viewModel.play()
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
    // 1️⃣ Breathing settings repository
    let breathingRepo = LocalBreathingRepository()
    let initialSettings = breathingRepo.load()

    // 2️⃣ Library ViewModel
    let libraryVM = LibraryViewModel(
        repository: breathingRepo,
        initial: initialSettings
    )

    // 3️⃣ Scene settings ViewModel
    let sceneVM = SceneSettingsViewModel(
        repository: LocalBreathingSceneRepository()
    )

    // 4️⃣ Player ViewModel
    let playerVM = BreathingPlayerViewModel(
        libraryViewModel: libraryVM,
        sceneSettingsViewModel: sceneVM
    )

    // 5️⃣ Preview the view
    BreathingPlayer(viewModel: playerVM)
        .preferredColorScheme(.dark)
        .background(Color.black) // helps visibility in preview
}
