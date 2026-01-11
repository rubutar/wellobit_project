//
//  StressTimelinePoint.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import Foundation

struct StressTimelinePoint: Identifiable {
    let id = UUID()
    let date: Date
    let stressScore: Int
    let stressLevel: StressLevel
}
