//
//  ControlFloatingButton.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 23/01/26.
//

import SwiftUI

struct ControlFloatingButton: View {

    @ObservedObject var viewModel: BreathingPlayerViewModel
    @ObservedObject var libraryViewModel: LibraryViewModel
    @StateObject var sceneSettingsViewModel: SceneSettingsViewModel

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    NotificationCenter.default.post(name: .showBreathingControls, object: nil)
                }
            HStack {
                Spacer()
                BreathingPlayerControls(
                    viewModel: viewModel,
                    sceneSettingsViewModel: sceneSettingsViewModel
                )
            }
            .contentShape(Rectangle())
        }
    }
}

extension Notification.Name {
    static let showBreathingControls = Notification.Name("showBreathingControls")
}
