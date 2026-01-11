import SwiftUI

struct SleepScoreContainerView: View {

    @StateObject var viewModel: SleepScoreViewModel

    var body: some View {
        VStack(spacing: 16) {

            if let score = viewModel.sleepScore {
                SleepScoreGaugeView(score: score.value)
                SleepScoreSummaryView(score: score)
            } else {
                Text("Sleep score unavailable")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            await viewModel.loadSleepScore()
        }
    }
}
