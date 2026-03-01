//
//  StretchRoutine.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/02/26.
//


import Foundation

//struct StretchRoutine: Identifiable, Codable {
//    let id: String
//    let title: String
//    let description: String
//    let category: StretchCategory
//    let totalDuration: Int
//    let steps: [StretchStep]
//}

enum StretchCategory: String, Codable {
    case sleep
    case lowerBack
    case neck
    case wakeUp
    case fullBody
    case postureReset
}

struct StretchStepLibrary: Identifiable, Codable {
    let id: String
    let name: String
    let imageName: String
    let instructions: [String]
    let tips: [String]
    let modifications: [String]
    let benefits: [String]
    let caution: [String]
}

struct RoutineStepReference: Codable {
    let stepId: String
    let defaultDuration: Int
}

struct StretchRoutine: Identifiable {
    let id: String
    let title: String
    let description: String
    let category: StretchCategory
    let steps: [StretchStep]
}

struct StretchRoutineDTO: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let category: StretchCategory
    let steps: [RoutineStepReference]
}

struct StretchStep: Identifiable {
    let id: String
    let name: String
    let imageName: String
    let instructions: [String]
    let tips: [String]
    let modifications: [String]
    let benefits: [String]
    let caution: [String]
    let defaultDuration: Int
}

extension StretchRoutine {
    
    var totalDuration: Int {
        steps.reduce(0) { $0 + $1.defaultDuration }
    }
    
    var totalDurationInMinutes: Int {
        totalDuration / 60
    }
}
