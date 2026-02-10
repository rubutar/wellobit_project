//
//  AchievementUnlockedViewModel.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 04/02/26.
//

import Foundation
import Combine


@MainActor
final class AchievementUnlockedViewModel: ObservableObject {

    @Published private(set) var badge: Badge?
    @Published var isLoading = true

    private let sequence: Int
    private let badgeRepository: BadgeRepository

    init(
        sequence: Int,
        badgeRepository: BadgeRepository
    ) {
        self.sequence = sequence
        self.badgeRepository = badgeRepository
    }

    func onAppear() {
        Task {
            self.badge = await badgeRepository.getBadge(for: sequence)
            self.isLoading = false
        }
    }
}
