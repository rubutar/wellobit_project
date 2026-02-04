//
//  ProgressStore.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 02/02/26.
//


import Foundation
import Combine

@MainActor
final class ProgressStore: ObservableObject {

    @Published private(set) var progress: BreathingProgress

    private let repository: BreathingProgressRepository

    init(repository: BreathingProgressRepository) {
        self.repository = repository
        self.progress = repository.load()
        print("🟢 ProgressStore INIT:", ObjectIdentifier(self))
    }


    /// Call this when a breathing session finishes
    /// Returns true if a badge was earned
    func completeSession() -> Bool {

        var current = progress
        let today = Date.startOfToday()

        // Reset if new day
        if current.date != today {
            current = .empty(for: today)
        }

        current.completedSessions += 1

        let expectedBadges = current.completedSessions / 1
        let didEarnBadge = expectedBadges > current.badges

        current.badges = expectedBadges

        progress = current
        repository.save(current)

        print("📊 Progress updated:", current)
        print("🏅 Badge earned:", didEarnBadge)

        return didEarnBadge
    }
}
