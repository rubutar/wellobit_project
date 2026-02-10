//
//  LibrarySectionView.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 01/02/26.
//


// Presentation/Library/Components/LibrarySectionView.swift

import SwiftUI

struct LibrarySectionView: View {

    let title: String
    let sessions: [BreathingSession]
    let onSelect: (BreathingSession) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(sessions) { session in
                    BreathingCardView(session: session)
                        .onTapGesture {
                            onSelect(session)
                        }
                }
            }
        }
    }
}
