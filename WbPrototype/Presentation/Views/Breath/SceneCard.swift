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
    var accentColor: Color { Color("tmBlue") }


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
                        .foregroundColor(accentColor)
                        .padding(10)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isSelected ? Color.accentColor : Color.clear,
                        lineWidth: 3
                    )
            )

            // MARK: - Title below card
            Text(scene.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .background {
                    Text("Scenes")
                        .font(.title.weight(.semibold))
                        .foregroundStyle(.white)
                        .blur(radius: 8)
                }
                .lineLimit(1)
                .shadow(
                    color: isSelected ? accentColor.opacity(0.6) : .accentColor,
                    radius: 8
                )
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
    .preferredColorScheme(.light)
    .padding()
    .background(Color.white)
}
