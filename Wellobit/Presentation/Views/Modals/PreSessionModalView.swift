//
//  PreSessionModalView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 09/01/26.
//


import SwiftUI

struct PreSessionModalView: View {

    let cycles: Int
    let totalSeconds: Int
    let onContinue: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {

            Text("Breathing Session Starting")
                .font(.title2.bold())

            Text("You’re about to begin")
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("\(cycles) breathing cycles")
                Text("≈ \(formattedDuration)")
            }
            .font(.headline)

            Divider()

            Text(
                "For better HRV accuracy, please start a Mindfulness session on your Apple Watch."
            )
            .font(.footnote)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)

            Spacer()

            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                onCancel()
            } label: {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private var formattedDuration: String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes)m \(seconds)s"
    }
}


#Preview {
    PreSessionModalView(
        cycles: 4,
        totalSeconds: 240,
        onContinue: {
            print("Continue tapped")
        },
        onCancel: {
            print("Cancel tapped")
        }
    )
}
