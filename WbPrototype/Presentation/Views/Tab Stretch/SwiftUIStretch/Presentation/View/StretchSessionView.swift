//
//  StretchSessionView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/02/26.
//

import SwiftUI

struct StretchSessionView: View {
    
    @StateObject var viewModel: StretchSessionViewModel
    @State private var selectedStep: StretchStep?
    @State private var showStepSheet = false
    @State private var showSettings = false

    
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
                            Text("\(viewModel.preparationTime)")
                        }
                        else if viewModel.isInInterval {
                            Text("Rest")
                                .font(.headline)
                            
                            Text("\(viewModel.intervalRemaining)")
                                .font(.largeTitle.bold())
                        }
                        else {
                            Text("\(viewModel.remainingTime)s")
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
            .onChange(of: selectedStep != nil) { isPresented in
                if isPresented {
                    viewModel.pauseSession()
                }
            }
            .onAppear {
                viewModel.startSession()
            }
            .onDisappear {
                viewModel.pauseSession()
            }
            .onChange(of: showSettings) { isPresented in
                if isPresented {
                    viewModel.pauseSession()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                viewModel.pauseSession()
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
    
}
