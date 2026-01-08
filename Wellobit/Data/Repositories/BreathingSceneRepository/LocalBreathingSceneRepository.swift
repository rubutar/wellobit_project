//
//  LocalBreathingSceneRepository.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 08/01/26.
//

import Foundation


final class LocalBreathingSceneRepository: BreathingSceneRepository {

    private let sceneKey = "breathing_scene"

    let scenes: [BreathingScene] = [
        BreathingScene(
            id: "waterfall",
            title: "Waterfall",
            imageName: "waterfall",
            soundName: "waterfall"
        ),
        BreathingScene(
            id: "river",
            title: "River",
            imageName: "river",
            soundName: "river"
        ),
        BreathingScene(
            id: "beach",
            title: "Beach",
            imageName: "beach",
            soundName: "beach"
        )
    ]

    func loadSelectedScene() -> BreathingScene {
        guard
            let id = UserDefaults.standard.string(forKey: sceneKey),
            let scene = scenes.first(where: { $0.id == id })
        else {
            return scenes.first!
        }

        return scene
    }

    func saveSelectedScene(_ scene: BreathingScene) {
        UserDefaults.standard.set(scene.id, forKey: sceneKey)
    }
}
