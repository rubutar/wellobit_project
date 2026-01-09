//
//  ContentView.swift
//  WellobitWatch Watch App
//
//  Created by Rudi Butarbutar on 04/12/25.
//

import SwiftUI
import HealthKit

struct ContentView: View {

    @EnvironmentObject var viewModel: WatchWorkoutViewModel

    var body: some View {
        Group {
            if let cycles = viewModel.pendingCycles,
               let seconds = viewModel.pendingTotalSeconds {

                // 🔔 Pre-session prompt from iPhone
                WatchPreSessionView(
                    cycles: cycles,
                    totalSeconds: seconds,
                    onAcknowledge: {
                        startMindfulnessSession()
                    }
                )

            } else {
                mainWorkoutView
            }
        }
    }

    // MARK: - Original UI (extracted, unchanged)
    private var mainWorkoutView: some View {
        VStack(spacing: 8) {

            Text("Guided Breathing")
                .font(.headline)

            Text(viewModel.isWorkoutRunning
                 ? "Session Running"
                 : "Waiting for iPhone")
                .font(.caption)

//            Button(viewModel.isWorkoutRunning
//                   ? "Stop Session"
//                   : "Start (local)") {
//
//                if viewModel.isWorkoutRunning {
//                    viewModel.stopButtonTapped()
//                } else {
//                    // Optional: local testing on Watch only
//                    let config = HKWorkoutConfiguration()
//                    config.activityType = .running
//                    config.locationType = .outdoor
//                    viewModel.startWorkout(with: config)
//                }
//            }
        }
        .padding()
    }

    // MARK: - Mindfulness Start
    private func startMindfulnessSession() {
        let config = HKWorkoutConfiguration()
        config.activityType = .mindAndBody
        config.locationType = .unknown

        viewModel.startWorkout(with: config)

        // Clear pre-session prompt
        viewModel.pendingCycles = nil
        viewModel.pendingTotalSeconds = nil
    }
}
