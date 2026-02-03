//
//  BadgePopupView.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 02/02/26.
//


import SwiftUI

struct BadgePopupView: View {

    let onNiceTapped: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("🎉")
                    .font(.system(size: 64))

                Text("Great job!")
                    .font(.title)
                    .bold()

                Text("You earned a badge today!")
                    .multilineTextAlignment(.center)

                Button("Nice!") {
                    onNiceTapped()
                }
                .padding(.top, 12)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
            )
            .padding(40)
        }
    }
}
