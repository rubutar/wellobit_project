//
//  LibraryView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.


import SwiftUI
import WatchConnectivity

struct LibraryView: View {
    @StateObject var libraryViewModel: LibraryViewModel
    @StateObject var sceneSettingsViewModel: SceneSettingsViewModel
    @StateObject var playerViewModel: BreathingPlayerViewModel
    @Environment(\.dismiss) private var dismiss
    
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
            
            ZStack {
                Image(sceneSettingsViewModel.selectedScene.imageName)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    if playerViewModel.isResting {
                        Text("isResting : TRUE")
                    } else {
                        Text("isResting : FALSE")
                    }
                    
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
                
                if playerViewModel.showBadgePopup {
                    BadgePopupView {
                        playerViewModel.showBadgePopup = false
                    }
                    .zIndex(10)
                }
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    NotificationCenter.default.post(
                        name: .showBreathingControls,
                        object: nil
                    )
                }
            )
            
            
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
//        .navigationTitle("Library")
        .toolbar(.hidden, for: .tabBar) 
        .onAppear {
            playerViewModel.start()
        }
        .onDisappear {
            playerViewModel.pauseIfNeeded()
            playerViewModel.teardown()
        }
    }
}

