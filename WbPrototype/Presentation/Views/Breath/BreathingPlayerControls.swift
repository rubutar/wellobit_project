//
//  BreathingPlayerControls.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 23/01/26.
//


import SwiftUI

struct BreathingPlayerControls: View {

    @ObservedObject var viewModel: BreathingPlayerViewModel
    @ObservedObject var sceneSettingsViewModel: SceneSettingsViewModel
    @State private var isVisible = true
    @State private var hideWorkItem: DispatchWorkItem?


    @State private var showSceneList = false

    var body: some View {
        VStack(spacing: 12) {
            if viewModel.isPlaying {
                activeControls
            } else {
                inactiveControls
            }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 80)
        .opacity(shouldShowControls ? 1 : 0)
        .animation(.easeInOut(duration: 0.25), value: shouldShowControls)
        .onChange(of: viewModel.isPlaying) { isPlaying in
            if isPlaying {
                showThenAutoHide()
            } else {
                isVisible = true
                hideWorkItem?.cancel()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showBreathingControls)) { _ in
            guard viewModel.isPlaying else { return }
            showThenAutoHide()
        }

    }
    
    private func showThenAutoHide() {
        hideWorkItem?.cancel()
        isVisible = true

        let workItem = DispatchWorkItem {
            withAnimation {
                isVisible = false
            }
        }

        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem)
    }

    
    private var shouldShowControls: Bool {
        !viewModel.isPlaying || isVisible
    }

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


private extension BreathingPlayerControls {

    var inactiveControls: some View {
        VStack(spacing: 12) {
            toggleHapticsButton
            muteButton
            sceneButton
        }
    }

    var activeControls: some View {
        VStack(spacing: 12) {
            toggleHapticsButton
            muteButton
            pauseResumeButton
            stopButton
        }
    }

    var toggleHapticsButton: some View {
        Button {
            viewModel.toggleHaptics()
        } label: {
            Image(systemName: viewModel.isHapticsEnabled
                  ? "iphone.radiowaves.left.and.right"
                  : "iphone.slash")
                .modifier(ControlButtonStyle())
        }
    }

    var muteButton: some View {
        Button {
            viewModel.toggleMute()
        } label: {
            Image(systemName: viewModel.isMuted
                  ? "speaker.slash.fill"
                  : "speaker.wave.2.fill")
                .modifier(ControlButtonStyle())
        }
    }

    var pauseResumeButton: some View {
        Button {
            viewModel.isPaused ? viewModel.resume() : viewModel.pause()
        } label: {
            Image(systemName: viewModel.isPaused
                  ? "play.fill"
                  : "pause.fill")
                .modifier(ControlButtonStyle())
        }
    }

    var stopButton: some View {
        Button {
            viewModel.stop()
        } label: {
            Image(systemName: "xmark")
                .modifier(ControlButtonStyle())
        }
    }

    var sceneButton: some View {
        Button {
            showSceneList = true
        } label: {
            Image(systemName: "photo.stack")
                .modifier(ControlButtonStyle())
        }
        .sheet(isPresented: $showSceneList) {
            SceneListView(sceneSettingsVM: sceneSettingsViewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}
