//
//  SleepScoreContainerView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import SwiftUI

struct SleepScoreContainerView: View {

    @StateObject var viewModel: SleepScoreViewModel
    let date: Date

    var body: some View {
        VStack(spacing: 16) {

            if let score = viewModel.sleepScore {
                Text("Sleep Score (\(score.value))")
                    .font(.headline)
                HorizontalSegmentedGaugeView(score: score.value)
                SleepScoreSummaryView(score: score)
            } else {
                Text("Sleep score unavailable")
                    .foregroundColor(.secondary)
            }
        }
        .task(id: date) {
            await viewModel.loadSleepScore(for: date)
        }
    }
}
