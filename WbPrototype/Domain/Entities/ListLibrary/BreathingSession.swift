//
//  BreathingSession.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 01/02/26.
//


struct BreathingSession: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let tip: String

    let category: BreathingCategory
    let imageName: String
    let diagramImage: String
    let preset: BreathingPreset
}
