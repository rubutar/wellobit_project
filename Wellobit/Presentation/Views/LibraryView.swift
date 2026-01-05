//
//  LibraryView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import SwiftUI

struct LibraryView: View {
    @StateObject var viewModel: LibraryViewModel

    var body: some View {
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
    }
}
