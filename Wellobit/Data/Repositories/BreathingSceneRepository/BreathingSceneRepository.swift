//
//  BreathingSceneRepository.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 08/01/26.
//


protocol BreathingSceneRepository {
    var scenes: [BreathingScene] { get }
    func loadSelectedScene() -> BreathingScene
    func saveSelectedScene(_ scene: BreathingScene)
}