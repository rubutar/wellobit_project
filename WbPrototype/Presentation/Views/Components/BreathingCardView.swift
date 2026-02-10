//
//  BreathingCardView.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 01/02/26.
//


// Presentation/Library/Components/BreathingCardView.swift

import SwiftUI

struct BreathingCardView: View {

    let session: BreathingSession

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(session.imageName)
                .resizable()
                .scaledToFill()

            LinearGradient(
                colors: [.black.opacity(0.4), .clear],
                startPoint: .bottom,
                endPoint: .top
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)

                Text(session.subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
            }
            .padding()
        }
        .frame(width: 150, height: 166)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
