//
//  HRVPoint.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 17/01/26.
//

import Foundation


struct HRVPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let type: HRVType
}

enum HRVType {
    case rmssd
    case sdnn
}

extension Array where Element == HRVPoint {
    var averageValue: Double? {
        guard !isEmpty else { return nil }
        return map(\.value).reduce(0, +) / Double(count)
    }
    var latestValue: Double? {
        guard let latest = self.max(by: { $0.date < $1.date }) else {
            return nil
        }
        return latest.value
    }
}

