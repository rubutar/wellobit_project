//
//  ContentView.swift
//  WellobitWatch Watch App
//
//  Created by Rudi Butarbutar on 04/12/25.
//

// ContentView.swift (watchOS)
import SwiftUI
import HealthKit

struct ContentView: View {
    @EnvironmentObject var viewModel: WatchWorkoutViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Guided Breathing")
                .font(.headline)
            
            Text(viewModel.isWorkoutRunning ? "Session Running" : "Waiting for iPhone")
                .font(.caption)
            
            Button(viewModel.isWorkoutRunning ? "Stop Session" : "Start (local)") {
                if viewModel.isWorkoutRunning {
                    viewModel.stopButtonTapped()
                } else {
                    // optional: local start if you want to test on watch only
                    let config = HKWorkoutConfiguration()
                    config.activityType = .running
                    config.locationType = .outdoor
                    viewModel.startWorkout(with: config)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
