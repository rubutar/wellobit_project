//
//  LibraryView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import SwiftUI

struct LibraryView: View {

    // MARK: - ViewModels (owned here)
    @StateObject private var libraryViewModel: LibraryViewModel
    @StateObject private var sceneSettingsViewModel: SceneSettingsViewModel
    @StateObject private var playerViewModel: BreathingPlayerViewModel

    private let router = LibraryRouter()

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
        NavigationStack(path: $libraryViewModel.navigationPath) {
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
                    BreathingPlayer(viewModel: playerViewModel)
                    BreathingPhaseSelector(viewModel: libraryViewModel)
                        .opacity(playerViewModel.isPlaying ? 0 : 1)
                        .allowsHitTesting(!playerViewModel.isPlaying)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
////                        playerViewModel.stop()
//                        libraryViewModel.openScenes()
//                    } label: {
//                        Image(systemName: "rectangle.on.rectangle.badge.gearshape")
//                            .foregroundColor(.white)
//                    }
//                }
//            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        libraryViewModel.openScenes()
                    } label: {
                        Image(systemName: "rectangle.on.rectangle.badge.gearshape")
                            .foregroundColor(.white)
                            .opacity(playerViewModel.isPlaying ? 0 : 1)
                    }
                    .allowsHitTesting(!playerViewModel.isPlaying)
                }
            }
            .navigationDestination(for: LibraryDestination.self) { destination in
                router.makeDestination(
                    destination,
                    sceneSettingsVM: sceneSettingsViewModel
                )
            }
        }
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
