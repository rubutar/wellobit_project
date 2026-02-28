//
//  StretchRoutineListView.swift
//  Wellobit
//
//  Created by Rudi LibraryButarbutar on 27/02/26.
//

import SwiftUI
import Combine

struct StretchRoutineListView: View {
    
    @StateObject private var viewModel =
    StretchRoutineListViewModel(repository: LocalStretchRepository())
    
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
        }
    }
}
