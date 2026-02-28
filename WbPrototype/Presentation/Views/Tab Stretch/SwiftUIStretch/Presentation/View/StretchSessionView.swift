//
//  StretchSessionView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/02/26.
//

import SwiftUI

struct StretchSessionView: View {
    
    @ObservedObject var viewModel: StretchSessionViewModel
    @State private var selectedStep: StretchStep?
    @State private var showStepSheet = false
    
    var body: some View {
        NavigationStack {
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
                
                VStack(spacing: 24) {
                    
//                    Text(viewModel.routine.title)
//                        .font(.title2.bold())
                    
                    if let step = viewModel.currentStep {
                        
                        HStack {
                            Text(step.name)
                                .font(.headline)
                            Button {
                                selectedStep = step
                                showStepSheet = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .font(.title3)
                            }
                        }
                        Image(step.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(16)
                        
                        if viewModel.isPreparing {
                            Text("Get Ready")
                                .font(.headline)
                            
                            Text("\(viewModel.preparationTime)")
                                .font(.largeTitle.bold())
                        } else {
                            Text("\(viewModel.remainingTime)s")
                                .font(.largeTitle.bold())
                        }
                    }
                    
                    HStack(spacing: 24) {
                        
                        Button("Previous") {
                            viewModel.previousStep()
                        }
                        
                        Button(viewModel.isRunning ? "Pause" : "Resume") {
                            if viewModel.isRunning {
                                viewModel.pauseSession()
                            } else {
                                viewModel.resumeSession()
                            }
                        }
                        
                        Button("Next") {
                            viewModel.nextStep()
                        }
                    }
                    
                    if viewModel.isCompleted {
                        Text("Session Completed 🎉")
                            .foregroundColor(.green)
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.routine.title)
            .sheet(item: $selectedStep) { step in
                StepInfoSheet(step: step)
            }
            .onAppear {
                viewModel.startSession()
            }
        }
    }
}
