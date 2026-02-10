//
//  BreathingProgress.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 02/02/26.
//

import Foundation


struct BreathingProgress: Codable, Equatable {

    var date: Date          // start-of-day date
    var completedSessions: Int
    var badges: Int

    static func empty(for date: Date) -> BreathingProgress {
        BreathingProgress(
            date: date,
            completedSessions: 0,
            badges: 0
        )
    }
}

