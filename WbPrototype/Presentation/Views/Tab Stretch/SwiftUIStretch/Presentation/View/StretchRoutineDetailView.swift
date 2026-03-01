//
//  StretchRoutineDetailView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/02/26.
//

import SwiftUI

struct StretchRoutineDetailView: View {
    
    let routine: StretchRoutine
    
    @State private var customDurations: [String: Int] = [:]
    @State private var selectedStep: StretchStep?
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.tmGRGreen.opacity(0),
                    Color.tmGRGreen.opacity(1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text(routine.title)
                        .font(.title.bold())
                    
                    Text(routine.description)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    ForEach(routine.steps) { step in
                        VStack(alignment: .leading, spacing: 8) {
                            
                            HStack {
                                //                            Image(step.imageName)
                                Image(systemName: "figure.cooldown")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .cornerRadius(6)
                                
                                Text(step.name)
                                    .font(.headline)
                                    .onTapGesture {
                                        selectedStep = step
                                    }
                                
                                Spacer()
                                
//                                Button {
//                                    selectedStep = step
//                                    showStepSheet = true
//                                } label: {
//                                    Image(systemName: "info.circle")
//                                        .font(.title3)
//                                }
                                HStack(spacing: 12) {
                                    
                                    Button {
                                        let current = customDurations[step.id, default: step.defaultDuration]
                                        if current > 10 {
                                            customDurations[step.id] = current - 15
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title3)
                                    }
                                    
                                    Text(formatTime(customDurations[step.id, default: step.defaultDuration]))
                                        .font(.subheadline.monospacedDigit())
                                        .frame(minWidth: 50)
                                    
                                    Button {
                                        let current = customDurations[step.id, default: step.defaultDuration]
                                        if current < 900 {
                                            customDurations[step.id] = current + 15
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title3)
                                    }
                                }
//                                Stepper(
//                                    "\(customDurations[step.id, default: step.defaultDuration]) sec",
//                                    value: Binding(
//                                        get: {
//                                            customDurations[step.id, default: step.defaultDuration]
//                                        },
//                                        set: {
//                                            customDurations[step.id] = min($0, 900) // 15 min max
//                                        }
//                                    ),
//                                    in: 10...900,
//                                    step: 15
//                                )
                            }
                            

                        }
                    }
                    
                    
//                    NavigationLink {
//                        StretchSessionView(
//                            viewModel: StretchSessionViewModel(
//                                routine: routine,
//                                customizedDurations: customDurations
//                            )
//                        )
//                    } label: {
//                        Text("Start Session")
//                            .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .padding(.top)
                }
                .padding()
            }
            .safeAreaInset(edge: .bottom) {
                NavigationLink {
                    StretchSessionView(
                        viewModel: StretchSessionViewModel(
                            routine: routine,
                            customizedDurations: customDurations
                        )
                    )
                } label: {
                    Text("Start Session")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .sheet(item: $selectedStep) { step in
                StepInfoSheet(step: step)
            }
            .sheet(isPresented: $showSettings) {
                StretchPreferencesView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                    }
                }
            }
            
        }
    }
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
