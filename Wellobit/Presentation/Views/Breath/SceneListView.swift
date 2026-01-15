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
        ZStack {
            Image(sceneSettingsVM.selectedScene.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
                .opacity(0.3)

//            Color.black.opacity(0.25)
//                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                Spacer()
                
                Text("Scenes")
                    .font(.title2)
                    .bold()
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
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button {
//                        dismiss()
//                    } label: {
//                        Image(systemName: "xmark")
//                    }
//                }
//            }
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
