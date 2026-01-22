//
//  SleepHistoryRange.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


enum SleepHistoryRange {
    case week
    case twoWeeks
    case month
    case threeMonths

    var days: Int {
        switch self {
        case .week:
            return 7
        case .twoWeeks:
            return 14
        case .month:
            return 30
        case .threeMonths:
            return 90
        }
    }
}
