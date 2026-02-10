//
//  Badge.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 04/02/26.
//

import Foundation


struct Badge: Identifiable, Equatable, Decodable, Encodable {
    let id: String
    let title: String
    let description: String
    let imageName: String
    let imageBadge: String
    let earnedAt: Date?
}

struct BadgeProgress: Identifiable, Equatable, Decodable, Encodable {
    let id: String
    var badge: Badge
    var status: BadgeStatus
    var remainingSessions: Int?
}

enum BadgeStatus: String, Codable {
    case locked
    case active
    case earned
}

extension Badge {
    func withEarnedDateIfNeeded(_ earned: Bool) -> Badge {
        guard earned else { return self }
        return Badge(
            id: id,
            title: title,
            description: description,
            imageName: imageName,
            imageBadge: imageBadge,
            earnedAt: Date()
        )
    }
}

final class LocalBadgeRepository {

    private let key = "local_badge_progress"

    func load() -> [BadgeProgress] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let badges = try? JSONDecoder().decode([BadgeProgress].self, from: data)
        else {
            return BadgeProgressViewModel.mockData
        }

        return badges
    }

    func save(_ badges: [BadgeProgress]) {
        guard let data = try? JSONEncoder().encode(badges) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
