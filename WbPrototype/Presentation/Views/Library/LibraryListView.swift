//
//  LibraryListView.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 01/02/26.
//

import SwiftUI
import Combine
struct LibraryListView: View {
    @ObservedObject private var viewModel: LibraryListViewModel
    @ObservedObject private var playerViewModel: BreathingPlayerViewModel

    private let makeLibrary: () -> AnyView

    init(
        viewModel: LibraryListViewModel,
        playerViewModel: BreathingPlayerViewModel,
        makeLibrary: @escaping () -> AnyView
    ) {
        self.viewModel = viewModel
        self.playerViewModel = playerViewModel
        self.makeLibrary = makeLibrary
    }

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            content
                .navigationTitle("Library")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(for: LibraryRoute.self) { route in
                    switch route {
                    case .detail(let session):
                        LibraryDetailedView(
                            playerViewModel: playerViewModel,
                            session: session,
                            onStart: {
                                viewModel.startSession(session)
                            }
                        )

                    case .player:
                        makeLibrary()
                    }
                }
        }
    }

    private var content: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.tmGRYellow,
                    Color.tmGRGreen
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                
//                BadgeEarnedHeaderView()
                
                VStack(spacing: 24) {
                    ForEach(BreathingCategory.allCases, id: \.self) { category in
                        if let sessions = viewModel.sessionsByCategory[category] {
                            LibrarySectionView(
                                title: category.rawValue,
                                sessions: sessions,
                                onSelect: viewModel.select
                            )
                        }
                    }
                }
                .padding()
            }
        }
    }
}


