//
//  SleepScoreSummaryView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import SwiftUI

struct SleepScoreSummaryView: View {

    let score: SleepScore

    var body: some View {
        VStack(spacing: 6) {
            Text(scoreLabel)
                .font(.headline)

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }

    private var scoreLabel: String {
        score.label.rawValue.capitalized
    }

    private var description: String {
        switch score.label {
        case .excellent:
            return "Your body is well rested and recovered."
        case .good:
            return "You slept well, with minor room for improvement."
        case .fair:
            return "Your sleep was okay, but recovery could be better."
        case .poor:
            return "Your sleep quality was low. Consider resting today."
        }
    }
}
