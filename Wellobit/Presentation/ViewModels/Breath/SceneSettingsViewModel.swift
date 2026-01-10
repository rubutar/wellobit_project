//
//  SceneSettingsViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 08/01/26.
//


import Foundation
import Combine

final class SceneSettingsViewModel: ObservableObject {

    // MARK: - Published
    @Published private(set) var selectedScene: BreathingScene

    // MARK: - Dependencies
    private let repository: BreathingSceneRepository

    var scenes: [BreathingScene] {
        repository.scenes
    }

    // MARK: - Init
    init(repository: BreathingSceneRepository) {
        self.repository = repository
        self.selectedScene = repository.loadSelectedScene()
    }

    // MARK: - Intent
    func select(_ scene: BreathingScene) {
        guard selectedScene != scene else { return }

        selectedScene = scene
        repository.saveSelectedScene(scene)
    }
}

