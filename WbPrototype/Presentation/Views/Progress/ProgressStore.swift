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
    @Published var badges: [BadgeProgress]


    private let repository: BreathingProgressRepository

    init(repository: BreathingProgressRepository) {
          self.repository = repository
          self.progress = repository.load()
          self.badges = BadgeProgressViewModel.mockData
      }

    private let badgeMilestones = [3, 6, 9, 12, 15]

    /// Call this when a breathing session finishes
    /// Returns true if a badge was earned
    func completeSession() -> String? {

        var current = progress
        let today = Date.startOfToday()

        if current.date != today {
            current = .empty(for: today)
        }

        current.completedSessions += 1

        let newlyEarnedBadge = badgeMilestones
            .first { $0 == current.completedSessions }

        if newlyEarnedBadge != nil {
            current.badges += 1
        }

        progress = current
        repository.save(current)

        // ✅ return badge ID like "3", "6", etc.
        return newlyEarnedBadge.map { String($0) }
    }

    private func updateBadgeProgress(
        completedSessions: Int,
        badges: [BadgeProgress]
    ) -> [BadgeProgress] {

        let nextMilestone = badgeMilestones
            .first { $0 > completedSessions }

        return badges.map { progress in
            var updated = progress

            guard let total = BadgeRequirement.totalSessions[progress.id] else {
                return updated
            }

            if completedSessions >= total {
                updated.status = .earned
                updated.remainingSessions = nil
            } else if total == nextMilestone {
                updated.status = .active
                updated.remainingSessions = total - completedSessions
            } else {
                updated.status = .locked
                updated.remainingSessions = nil
            }

            return updated
        }
    }

}
