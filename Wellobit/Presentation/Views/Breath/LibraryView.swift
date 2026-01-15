//
//  LibraryView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import SwiftUI
import WatchConnectivity

struct LibraryView: View {

    // MARK: - ViewModels (owned here)
    @StateObject private var libraryViewModel: LibraryViewModel
    @StateObject private var sceneSettingsViewModel: SceneSettingsViewModel
    @StateObject private var playerViewModel: BreathingPlayerViewModel


    // MARK: - Init
    init(viewModel: LibraryViewModel) {
        _libraryViewModel = StateObject(wrappedValue: viewModel)

        let sceneVM = SceneSettingsViewModel(
            repository: LocalBreathingSceneRepository()
        )
        _sceneSettingsViewModel = StateObject(wrappedValue: sceneVM)

        _playerViewModel = StateObject(
            wrappedValue: BreathingPlayerViewModel(
                libraryViewModel: viewModel,
                sceneSettingsViewModel: sceneVM
            )
        )
    }

    // MARK: - Body
    var body: some View {
            ZStack {
                Image(sceneSettingsViewModel.selectedScene.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()

                Color.black.opacity(0.25)
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    Spacer()
                    BreathingPlayer(viewModel: playerViewModel, libraryViewModel: libraryViewModel, sceneSettingsViewModel: sceneSettingsViewModel)

                        .alert(
                            "Breathing Session Starting",
                            isPresented: $playerViewModel.showPreSessionModal
                        ) {
                            Button("Continue") {
                                playerViewModel.play()
                                
                            }

                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text(alertMessage)
                        }
                    BreathingPhaseSelector(viewModel: libraryViewModel)
                        .opacity(playerViewModel.isPlaying ? 0 : 1)
                        .allowsHitTesting(!playerViewModel.isPlaying)
                    
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
    
    private var alertMessage: String {
        let cycles = libraryViewModel.cycleCount
        let totalSeconds = libraryViewModel.totalDurationSeconds

        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return """
        You’re about to begin \(cycles) breathing cycles (~\(minutes)m \(seconds)s).

        For better HRV accuracy, please start a Mindfulness-style session on your Apple Watch.
        """
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
