//
//  CompleteBreathingSessionUseCase.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 02/02/26.
//

import Foundation

final class CompleteBreathingSessionUseCase {

    private let repository: BreathingProgressRepository

    init(repository: BreathingProgressRepository) {
        self.repository = repository
    }

    func execute() -> (progress: BreathingProgress, didEarnBadge: Bool) {

        let today = Date.startOfToday()
        var progress = repository.load()

        // 🔁 New day → reset progress
        if progress.date != today {
            progress = BreathingProgress.empty(for: today)
        }

        progress.completedSessions += 1

        let expectedBadges = progress.completedSessions / 3
        let didEarnBadge = expectedBadges > progress.badges

        progress.badges = expectedBadges
        repository.save(progress)

        return (progress, didEarnBadge)
    }
}
