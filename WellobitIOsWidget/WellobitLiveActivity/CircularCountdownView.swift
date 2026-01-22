//
//  CircularCountdownView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 06/01/26.
//


import SwiftUI

struct CircularCountdownView: View {
    let progress: Double
    let iconName: String
    let rotation: Double

    var body: some View {
        ZStack {
            ProgressView(value: progress)
                .progressViewStyle(.circular)

            Image(systemName: iconName)
                .font(.caption)
                .rotationEffect(.degrees(rotation))
        }
    }
}
