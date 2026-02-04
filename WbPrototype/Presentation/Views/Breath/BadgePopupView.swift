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
            Image("bgBadge")
                .resizable()
//                .scaledToFill()
                .ignoresSafeArea()

//            Color.black.opacity(0.05) // optional soft overlay
//                .ignoresSafeArea()

            VStack(spacing: 24) {

                Spacer(minLength: 40)

                // Title
                VStack(spacing: 8) {
                    Text("Achievement\nUnlocked 🎉")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)


                    Text("Added to your collection")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.6))
                }

                Spacer(minLength: 20)

                // Card
                VStack(spacing: 16) {

                    Image("imBadge")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .cornerRadius(16)

                    Text("Rooted Calm")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)

                    Text("""
                    Stability isn’t found outside.
                    It’s built from within.
                    That’s where calm takes root.
                    """)
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)


                    Text("04 Feb 26")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black.opacity(0.8))
                        .padding(.top, 8)
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(28)
                .shadow(
                    color: .black.opacity(0.12),
                    radius: 20,
                    y: 10
                )
                .padding(.horizontal, 20)

                Spacer()

                // Buttons
                VStack(spacing: 12) {

                    Button {
                        // TODO: share
                    } label: {
                        Text("Share this")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.button)
                            .cornerRadius(30)
                    }

                    Button {
                        onNiceTapped()
                    } label: {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.button)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(30)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            
        }
        .ignoresSafeArea(edges: .all)

    }
    
}

#Preview {
    var showBadgePopup = true
    BadgePopupView {
        showBadgePopup = false
    }
    .zIndex(100)
}

