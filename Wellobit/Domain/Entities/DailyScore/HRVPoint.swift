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
