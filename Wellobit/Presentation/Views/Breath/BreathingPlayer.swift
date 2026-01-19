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
    @StateObject var sceneSettingsViewModel: SceneSettingsViewModel
    @State private var showSceneList = false

    
    var body: some View {
        ZStack() {
            VStack() {
                topText
                    .frame(height: 10)
                
                breathingCore
                
                bottomText
                    .frame(height: 10)
            }
            .animation(.easeInOut, value: viewModel.uiState)
            
            HStack() {
                Spacer()
                controlButtons
                    .padding(.trailing, 0)
                    .padding(.bottom, 8)
                    .offset(y: 100)
            }
        }
    }
}

// MARK: - Subviews
private extension BreathingPlayer {
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
    
    // Breathing core (center button fixed)
    var breathingCore: some View {
        ZStack {
            BreathingCircle(
                phase: viewModel.currentPhase,
                progress: viewModel.phaseProgress
            )
            .opacity(viewModel.uiState == .breathing ? 1 : 0)
            
            if shouldShowCenterPlayButton {
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
                    .transition(.opacity)
            }
        }
    }
    
    var shouldShowCenterPlayButton: Bool {
        !viewModel.isPlaying
    }
    
    var centerPhaseText: String {
        guard let phase = viewModel.currentPhase else { return "" }
        
        switch phase {
        case .inhale:
            return "Inhale"
        case .holdIn:
            return "Hold"
        case .exhale:
            return "Exhale"
        case .holdOut:
            return "Hold"
        }
    }
    
    
    // Bottom phase text
    var bottomText: some View {
        //        Text(phaseLabel)
        Text("")
            .font(.title2.bold())
            .foregroundColor(.white)
            .opacity(viewModel.uiState == .breathing ? 1 : 0)
    }
    
    
    // Floating controls (DO NOT affect layout)
    var controlButtons: some View {
        VStack(spacing: 12) {
            
            if viewModel.isPlaying {
                activeSessionControls
            } else {
                inactiveSessionView
            }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 80)
        .opacity(viewModel.isPlaying || showInactiveControls ? 1 : 0)
        .allowsHitTesting(true)
    }
    
    var inactiveSessionView: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.toggleHaptics()
            } label: {
                Image(systemName: viewModel.isHapticsEnabled
                      ? "iphone.radiowaves.left.and.right"
                      : "iphone.slash")
                .modifier(ControlButtonStyle())
            }
            
            Button {
                showSceneList = true
            } label: {
                Image(systemName: "photo.stack")
                    .modifier(ControlButtonStyle())
            }
            .sheet(isPresented: $showSceneList) {
                SceneListView(sceneSettingsVM: sceneSettingsViewModel)
            }
        }
    }

    
    
    var activeSessionControls: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.toggleHaptics()
            } label: {
                Image(systemName: viewModel.isHapticsEnabled
                      ? "iphone.radiowaves.left.and.right"
                      : "iphone.slash")
                .modifier(ControlButtonStyle())
            }
            Button {
                viewModel.toggleMute()
            } label: {
                Image(systemName: viewModel.isMuted
                      ? "speaker.slash.fill"
                      : "speaker.wave.2.fill")
                .modifier(ControlButtonStyle())
            }
            
            // ⏸ Pause / Resume
            Button {
                viewModel.isPaused
                ? viewModel.resume()
                : viewModel.pause()
            } label: {
                Image(systemName: viewModel.isPaused
                      ? "play.fill"
                      : "pause.fill")
                .modifier(ControlButtonStyle())
            }
            
            // ❌ Cancel
            Button {
                viewModel.stop()
            } label: {
                Image(systemName: "xmark")
                    .modifier(ControlButtonStyle())
            }
        }
    }
    
    private var showInactiveControls: Bool {
        true
    }
    
    
    
    struct ControlButtonStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black.opacity(0.4))
                .clipShape(Circle())
        }
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
            //        } else if viewModel.isPaused {
            //            viewModel.resume()
        } else {
            //            viewModel.resume()
            //            viewModel.pause()
        }
    }
    
    var phaseLabel: String {
        guard let phase = viewModel.currentPhase else { return "" }
        return "\(phase.rawValue.capitalized) (\(viewModel.remainingSeconds))"
    }
    
//    var buttonIcon: String {
//        if !viewModel.isPlaying {
//            return "play.fill"
//        } else if viewModel.isPaused {
//            return ""
//        } else {
//            return ""
//        }
//    }
}



//#Preview {
//    let breathingRepo = LocalBreathingRepository()
//    let initialSettings = breathingRepo.load()
//
//    let libraryVM = LibraryViewModel(
//        repository: breathingRepo,
//        initial: initialSettings
//    )
//
//    let sceneVM = SceneSettingsViewModel(
//        repository: LocalBreathingSceneRepository()
//    )
//
//    let playerVM = BreathingPlayerViewModel(
//        libraryViewModel: libraryVM,
//        sceneSettingsViewModel: sceneVM
//    )
//
//    BreathingPlayer(viewModel: playerVM, libraryViewModel: libraryVM)
//        .preferredColorScheme(.dark)
//        .background(Color.white)
//}

#Preview {
    let repo = LocalBreathingRepository()
    let initialSettings = repo.load()
    let libraryVM = LibraryViewModel(
        repository: repo,
        initial: initialSettings
    )
    LibraryView(viewModel: libraryVM)
}
