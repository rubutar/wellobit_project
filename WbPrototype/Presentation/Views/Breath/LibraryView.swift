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
    @Environment(\.dismiss) private var dismiss
    
    
    
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
        NavigationStack {
            ZStack {
                Image(sceneSettingsViewModel.selectedScene.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
                
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                
                ZStack {
                    Image(sceneSettingsViewModel.selectedScene.imageName)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    Color.black.opacity(0.25)
                        .ignoresSafeArea()

                    VStack {
                        Spacer()

                        BreathingPlayer(
                            viewModel: playerViewModel,
                            libraryViewModel: libraryViewModel,
                            sceneSettingsViewModel: sceneSettingsViewModel
                        )

                        BreathingPhaseSelector(viewModel: libraryViewModel)
                            .opacity(playerViewModel.isPlaying ? 0 : 1)
                            .allowsHitTesting(!playerViewModel.isPlaying)

                        Spacer()
                    }

                    HStack {
                        Spacer()
                        BreathingPlayerControls(
                            viewModel: playerViewModel,
                            sceneSettingsViewModel: sceneSettingsViewModel
                        )
                    }
                    .padding(.top, 100)
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        NotificationCenter.default.post(
                            name: .showBreathingControls,
                            object: nil
                        )
                    }
                )
                .navigationBarBackButtonHidden(true)

                
//                ZStack {
//                    ControlFloatingButton(viewModel: playerViewModel, libraryViewModel: libraryViewModel, sceneSettingsViewModel: sceneSettingsViewModel)
//                        .padding(.top, 100)
//                    VStack {
//                        Spacer()
//                        Spacer()
//                        BreathingPlayer(viewModel: playerViewModel, libraryViewModel: libraryViewModel, sceneSettingsViewModel: sceneSettingsViewModel)
//                        //                        .alert(
//                        //                            "Breathing Session Starting",
//                        //                            isPresented: $playerViewModel.showPreSessionModal
//                        //                        ) {
//                        //                            Button("Continue") {
//                        //                                playerViewModel.play()
//                        //
//                        //                            }
//                        //
//                        //                            Button("Cancel", role: .cancel) { }
//                        //                        } message: {
//                        //                            Text(alertMessage)
//                        //                        }
//                        
//                        BreathingPhaseSelector(viewModel: libraryViewModel)
//                            .opacity(playerViewModel.isPlaying ? 0 : 1)
//                            .allowsHitTesting(!playerViewModel.isPlaying)
//                        Spacer()
//                        Spacer()
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 32)
//                .navigationBarBackButtonHidden(true)
                //                .toolbar {
                //                    ToolbarItem(placement: .navigationBarLeading) {
                //                        Button {
                //                            dismiss()
                //                        } label: {
                //                            Image(systemName: "chevron.left")
                //                                .foregroundColor(.black)
                //                        }
                //                    }
                //                }
                
                
                
                if playerViewModel.showPreSessionModal {
                    MindfulnessOverlay(
                        onConfirm: {
                            playerViewModel.showPreSessionModal = false
                            playerViewModel.play()
                        },
                        onClose: {
                            playerViewModel.showPreSessionModal = false
                        }
                    )
                }
                
            }
        }
    }
    
    
    //    private var alertMessage: String {
    //        let cycles = libraryViewModel.cycleCount
    //        let totalSeconds = libraryViewModel.totalDurationSeconds
    //
    //        let minutes = totalSeconds / 60
    //        let seconds = totalSeconds % 60
    //
    //        return """
    //        You’re about to begin \(cycles) breathing cycles (~\(minutes)m \(seconds)s).
    //
    //        For better HRV accuracy, please start a Mindfulness-style session on your Apple Watch.
    //        """
    //    }
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
