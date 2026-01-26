//
//  SceneListView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 08/01/26.
//


import SwiftUI

struct SceneListView: View {
    
    @ObservedObject var sceneSettingsVM: SceneSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            ZStack {
                Image(sceneSettingsVM.selectedScene.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
                    .opacity(1)
                
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    Spacer()
                    
                    //                Text("Scenes")
                    //                    .font(.title2)
                    //                    .bold()
                    //                    .padding(.horizontal)
                    Text("Scenes")
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(.white)
                        .background {
                            Text("Scenes")
                                .font(.title.weight(.semibold))
                                .foregroundStyle(.white)
                                .blur(radius: 8)
                        }
                        .padding(.horizontal)
                    
                    
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(sceneSettingsVM.scenes) { scene in
                                SceneCard(
                                    scene: scene,
                                    isSelected: scene == sceneSettingsVM.selectedScene
                                )
                                .onTapGesture {
                                    sceneSettingsVM.select(scene)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}

#Preview {
    let sceneVM = SceneSettingsViewModel(
        repository: LocalBreathingSceneRepository()
    )

    NavigationStack {
        SceneListView(sceneSettingsVM: sceneVM)
    }
    .preferredColorScheme(.dark)
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
