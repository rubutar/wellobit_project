//
//  MindfulnessOverlay.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 22/01/26.
//

import SwiftUI


struct MindfulnessOverlay: View {
    let onConfirm: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            ZStack {
                Color("tmBGEAFAF0")
                
                VStack(spacing: 20) {
                    HStack(spacing: 12) {
                        Spacer()
                        Image("AppleWatch_Step1")
                            .resizable()
                            .frame(width: 28, height: 28)

                        Text("Start Mindfulness?")
                            .font(.system(size: 20, weight: .semibold))

                        Spacer()

                        Button {
                            onClose()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    ZStack {
                        Color.white

                        VStack(spacing: 20) {

                            // CONTENT
                            HStack(spacing: 16) {
                                Image("icn_apple_watch")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36)

                                Text("Start mindful breathe session on your Apple Watch to track HRV during this breathwork")
                                .font(.system(size: 14))
                                .foregroundColor(.black.opacity(0.65))
                                .fixedSize(horizontal: false, vertical: true)
                            }

                            Button {
                                onConfirm()
                            } label: {
                                Text("Got it, I’ll start it")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        Color("Vegal_Balanced")
                                    )
                                    .cornerRadius(26)
                            }
                        }
                        .padding(10)
                    }
                    .cornerRadius(20)
                    .padding(.horizontal, 9)
                    .padding(.bottom, 10)
                }
            }
            .cornerRadius(28)
            .padding(.horizontal, 24)
            .frame(height: 280)
        }
        .transition(.scale.combined(with: .opacity))
    }
}


#Preview {
    ZStack {
        // Fake background (to simulate your scene image)
        Color.gray.opacity(0.3)
            .ignoresSafeArea()

        MindfulnessOverlay(
            onConfirm: {
                print("Confirm tapped")
            },
            onClose: {
                print("Close tapped")
            }
        )
    }
}
