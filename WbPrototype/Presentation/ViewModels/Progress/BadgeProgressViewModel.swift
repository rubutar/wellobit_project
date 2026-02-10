//
//  BadgeProgressViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 06/02/26.
//


import Foundation
import Combine

final class BadgeProgressViewModel: ObservableObject {
    @Published var progresses: [BadgeProgress] = []
    @Published var selectedBadge: Badge? = nil
    @Published var showBadgePopup: Bool = false
    @Published var isPopupLoading: Bool = false

    private let repository: LocalBadgeRepository
    private let badgeRules: [(id: String, required: Int)] = [
        ("3", 3),
        ("6", 6),
        ("9", 9),
        ("12", 12),
        ("15", 15)
    ]
    
    init(
        repository: LocalBadgeRepository = LocalBadgeRepository(),
        useMockData: Bool = false
    ) {
        self.repository = repository

        if useMockData {
            self.progresses = Self.mockData
        } else {
            self.progresses = repository.load()
        }
    }

    // MARK: - Actions

    func selectBadge(_ progress: BadgeProgress) {
        selectedBadge = progress.badge
        showBadgePopup = true
        isPopupLoading = false
    }

    func closeBadgePopup() {
        showBadgePopup = false
        selectedBadge = nil
        isPopupLoading = false
    }

    func updateBadgeProgress(completedSessions: Int) {

        // 1️⃣ Sort rules by required sessions
        let sortedRules = badgeRules.sorted { $0.required < $1.required }

        // 2️⃣ Find the next badge that is NOT yet earned
        let nextActiveRule = sortedRules.first {
            completedSessions < $0.required
        }

        progresses = progresses.map { progress in
            var updated = progress

            guard let rule = sortedRules.first(where: { $0.id == progress.id }) else {
                return updated
            }

            if completedSessions >= rule.required {
                // ✅ Earned
                updated.status = .earned
                updated.remainingSessions = nil

                if updated.badge.earnedAt == nil {
                    updated.badge = updated.badge.withEarnedDateIfNeeded(true)
                }

            } else if rule.id == nextActiveRule?.id {
                // ✅ Active (ONLY ONE)
                updated.status = .active
                updated.remainingSessions = rule.required - completedSessions

            } else {
                // ✅ Locked
                updated.status = .locked
                updated.remainingSessions = nil
            }

            return updated
        }
    }
}

extension BadgeProgressViewModel {

    static let mockData: [BadgeProgress] = [
        BadgeProgress(
            id: "3",
            badge: Badge(
                id: "3",
                title: "Rooted Calm",
                description: """
                Stability isn’t found outside.
                It’s built from within.
                That’s where calm takes root.
                """,
                imageName: "1imBadge",
                imageBadge: "11imBadge",
                earnedAt: Date()
            ),
            status: .active,
            remainingSessions: 3
        ),
        BadgeProgress(
            id: "6",
            badge: Badge(
                id: "6",
                title: "Blooming Strong",
                description: """
                Calm is not something we wait for.
                It’s something we practice.
                And it changes how we meet the day.
                """,
                imageName: "2imBadge",
                imageBadge: "22imBadge",
                earnedAt: Date()
            ),
            status: .locked,
            remainingSessions: nil
        ),
        BadgeProgress(
            id: "9",
            badge: Badge(
                id: "9",
                title: "Steady Growth",
                description: """
                Growth doesn’t need to be loud.
                Small steps still move forward.
                The direction matters.
                """,
                imageName: "3imBadge",
                imageBadge: "33imBadge",
                earnedAt: Date()
            ),
            status: .locked,
            remainingSessions: nil
        ),
        BadgeProgress(
            id: "12",
            badge: Badge(
                id: "12",
                title: "Still Locked",
                description: "",
                imageName: "4imBadge",
                imageBadge: "44imBadge",
                earnedAt: nil
            ),
            status: .locked,
            remainingSessions: nil
        ),
        BadgeProgress(
            id: "15",
            badge: Badge(
                id: "15",
                title: "Still Locked",
                description: "",
                imageName: "5imBadge",
                imageBadge: "55imBadge",
                earnedAt: nil
            ),
            status: .locked,
            remainingSessions: nil
        )
    ]
}

enum BadgeRequirement {
    static let totalSessions: [String: Int] = [
        "3": 3,
        "6": 6,
        "9": 9,
        "12": 12,
        "15": 15
    ]
}


