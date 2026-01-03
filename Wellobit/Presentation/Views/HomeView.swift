//
//  ContentView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 04/12/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var sessionManager = PhoneSessionManager.shared
    @StateObject private var breathingViewModel: BreathingViewModel
    
    init() {
        let phoneHealthManager = PhoneHealthManager()
        let startUseCase = StartBreathingSessionUseCase(phoneHealthManager: phoneHealthManager)
        _breathingViewModel = StateObject(wrappedValue: BreathingViewModel(startBreathingUseCase: startUseCase))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("HRV Starter – iPhone")
                .font(.title)
                .bold()

            if let value = sessionManager.lastSentHRV {
                Text("Last sent HRV: \(value) ms")
            } else {
                Text("No HRV sent yet")
                    .foregroundStyle(.secondary)
            }

            Button("Send Dummy HRV to Watch") {
                sessionManager.sendDummyHRV()
            }
            .buttonStyle(.borderedProminent)
            Spacer()
            Button(
                breathingViewModel.isBreathing
                ? "Stop Workout Session"
                : "Start Workout Session"
            ) {
                if breathingViewModel.isBreathing {
                    breathingViewModel.stopButtonTapped()
                } else {
                    breathingViewModel.startButtonTapped()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    MainTabView()
}
