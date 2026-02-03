//
//  LocalBreathingProgressRepository.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 02/02/26.
//

import Foundation

protocol BreathingProgressRepository {
    func load() -> BreathingProgress
    func save(_ progress: BreathingProgress)
}


final class LocalBreathingProgressRepository: BreathingProgressRepository {

    private let key = "breathing.progress"

    func load() -> BreathingProgress {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let progress = try? JSONDecoder().decode(
                BreathingProgress.self,
                from: data
            )
        else {
            return .empty(for: Date.startOfToday())
        }

        return progress
    }


    func save(_ progress: BreathingProgress) {
        let data = try? JSONEncoder().encode(progress)
        UserDefaults.standard.set(data, forKey: key)
    }
}
