//
//  LibraryView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import SwiftUI

struct LibraryView: View {
    @StateObject var viewModel: LibraryViewModel
    private let router = LibraryRouter()

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack {
                Image("river")
                    .resizable()
                    .ignoresSafeArea()

                Color.black.opacity(0.25)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    BreathingPlayer(libraryViewModel: viewModel)

                    Spacer()

                    BreathingPhaseSelector(viewModel: viewModel)
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.openScenes()
                    } label: {
                        Image(systemName: "rectangle.on.rectangle.badge.gearshape")
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationDestination(for: LibraryDestination.self) { destination in
                router.makeDestination(destination)
            }
        }
    }
}
