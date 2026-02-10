//
//  LibraryListView.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 01/02/26.
//
////
//import SwiftUI
//
//struct LibraryListView: View {
//    
//    @ObservedObject private var viewModel: LibraryListViewModel
//    private let makeLibrary: () -> AnyView
//    
//    internal init(
//        viewModel: LibraryListViewModel,
//        makeLibrary: @escaping () -> AnyView
//        
//    ) {
//        self.viewModel = viewModel
//        self.makeLibrary = makeLibrary
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                LinearGradient(
//                    colors: [
//                        Color.tmGRYellow,
//                        Color.tmGRGreen
//                    ],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//                
//                ScrollView {
//                    ZStack {
//                        Color.white
//                        VStack(spacing: 24) {
//                            ForEach(BreathingCategory.allCases, id: \.self) { category in
//                                if let sessions = viewModel.sessionsByCategory[category] {
//                                    LibrarySectionView(
//                                        title: category.rawValue,
//                                        sessions: sessions,
//                                        onSelect: viewModel.select
//                                    )
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.top, 24)
//                        .padding(.bottom, 32)
//                    }
//                    .clipShape(
//                        RoundedRectangle(cornerRadius: 28, style: .continuous)
//                    )
//                    .shadow(
//                        color: .black.opacity(0.08),
//                        radius: 20,
//                        y: 10
//                    )
//                    .padding(.horizontal, 16)
//                    .padding(.top, 12)
//                }
//            }
//            //            .navigationTitle("Library")
//            //            .navigationBarTitleDisplayMode(.large)
//            //            .navigationDestination(item: $viewModel.selectedSession) { session in
//            //                LibraryDetailedView(
//            //                    session: session,
//            //                    onStart: {
//            //                        viewModel.startSession(session)
//            //                    }
//            //                )
//            //            }
//            //            .navigationDestination(isPresented: $viewModel.showPlayer) {
//            //                makeLibrary()
//            //            }
//            //        }
//            //    }
//            //}
//            .navigationDestination(item: $viewModel.selectedSession) { session in
//                LibraryDetailedView(
//                    session: session,
//                    onStart: {
//                        if #available(iOS 17.0, *) {
//                            // iOS 17+: push directly
//                            viewModel.startSession(session)
//                        } else {
//                            // iOS 16: dismiss first
//                            viewModel.startSession(session)
//                            viewModel.selectedSession = nil
//                        }
//                    }
//                )
//            }
//            
//            // PLAYER (parent-owned)
//            .navigationDestination(isPresented: $viewModel.showPlayer) {
//                makeLibrary()
//            }
//        }
//    }
//}

import Combine
import SwiftUI

struct LibraryListView: View {

    @ObservedObject private var viewModel: LibraryListViewModel
    private let makeLibrary: () -> AnyView

    init(
        viewModel: LibraryListViewModel,
        makeLibrary: @escaping () -> AnyView
    ) {
        self.viewModel = viewModel
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
