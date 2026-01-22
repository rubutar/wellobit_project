//
//  SleepTimelineStyle.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


import SwiftUI

enum SleepTimelineStyle {
    case week
    case twoWeeks
    case month
    case threeMonths

    var days: Int {
        switch self {
        case .week: return 7
        case .twoWeeks: return 14
        case .month: return 30
        case .threeMonths: return 90
        }
    }

    var xLabelInterval: Int {
        switch self {
        case .week: return 1
        case .twoWeeks: return 2
        case .month: return 6
        case .threeMonths: return 14
        }
    }

    var dotSize: CGFloat {
        switch self {
        case .week: return 6
        case .twoWeeks: return 5
        case .month: return 3
        case .threeMonths: return 1.5
        }
    }

    var lineWidth: CGFloat {
        switch self {
        case .week: return 2
        case .twoWeeks: return 1.5
        case .month: return 1
        case .threeMonths: return 0.5
        }
    }
}
