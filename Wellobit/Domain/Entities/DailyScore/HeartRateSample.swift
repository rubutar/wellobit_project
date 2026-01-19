//
//  HeartRateSample.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 18/01/26.
//


// Domain/Entities/HeartRateSample.swift

import Foundation

struct HeartRateSample: Identifiable {
    let id = UUID()
    let date: Date
    let bpm: Double
}
