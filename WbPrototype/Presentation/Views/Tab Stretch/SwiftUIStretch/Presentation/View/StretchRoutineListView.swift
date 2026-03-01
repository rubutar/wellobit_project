//
//  StretchRoutineListView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/02/26.
//

import SwiftUI

struct StretchRoutineListView: View {
    
    @StateObject private var viewModel =
    StretchRoutineListViewModel(repository: LocalStretchRepository())
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
                ScrollView {
                    VStack(spacing: 16) {
                        
                        ForEach(viewModel.routines) { routine in
                            NavigationLink {
                                StretchRoutineDetailView(routine: routine)
                            } label: {
                                RoutineCardView(routine: routine)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Stretch")
                .task {
                    await viewModel.loadRoutines()
                }
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
