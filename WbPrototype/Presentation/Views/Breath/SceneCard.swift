//
//  SceneCard.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 08/01/26.
//


import SwiftUI

struct SceneCard: View {
    let scene: BreathingScene
    let isSelected: Bool

    private let cardWidth: CGFloat = 160
    private let cardHeight: CGFloat = 280

    var body: some View {
        VStack(spacing: 8) {

            ZStack(alignment: .topTrailing) {
                Image(scene.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: cardHeight)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(10)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isSelected ? Color.white : Color.clear,
                        lineWidth: 3
                    )
            )

            // MARK: - Title below card
            Text(scene.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
        }
    }
}



#Preview("SceneCard – Selected") {
    SceneCard(
        scene: BreathingScene(
            id: "waterfall",
            title: "Waterfall",
            imageName: "waterfall",
            soundName: "waterfall"
        ),
        isSelected: true
    )
    .preferredColorScheme(.dark)
    .padding()
    .background(Color.black)
}
