//
//  WatchPreSessionView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 09/01/26.
//


//import SwiftUI
//
//struct WatchPreSessionView: View {
//
//    let cycles: Int
//    let totalSeconds: Int
//    let onGoToMindfulness: () -> Void
//
//    var body: some View {
//        VStack(spacing: 10) {
//
//            Text("Breathing Session")
//                .font(.headline)
//
//            VStack(spacing: 4) {
//                Text("\(cycles) cycles")
//                Text("≈ \(formattedDuration)")
//            }
//            .font(.subheadline)
//
//            Divider()
//
//            Text(
//                "For better HRV accuracy, start a Mindfulness session."
//            )
//            .font(.footnote)
//            .multilineTextAlignment(.center)
//            .lineLimit(3)
//            .fixedSize(horizontal: false, vertical: true)
//
//            Spacer()
//
//            Button("Go to Mindfulness") {
//                openMindfuonlnessApp()
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .padding()
//    }
//
//    private var formattedDuration: String {
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return "\(minutes)m \(seconds)s"
//    }
//    
//    func openMindfuonlnessApp() {
//        // For Apple's Mindfulness app
//        if let url = URL(string: "breathe://") {
//            WKExtension.shared().openSystemURL(url)
//        }
//    }
//}
//
//
//#Preview("Watch · Pre Session") {
//    WatchPreSessionView(
//        cycles: 4,
//        totalSeconds: 240,
//        onGoToMindfulness: {
//            print("Tapped")
//        }
//    )
//}


//
//  WatchPreSessionView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 09/01/26.
//

import SwiftUI

struct WatchPreSessionView: View {

    let cycles: Int
    let totalSeconds: Int
    let onAcknowledge: () -> Void

    @State private var didAcknowledge = false

    var body: some View {
        VStack(spacing: 10) {

            if didAcknowledge {
//                Text("Session started")
//                    .font(.headline)

                Text("Begin breathing exercise.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)

            } else {
                // 🔔 Reminder screen
                Text("Breathing Session")
                    .font(.headline)

                VStack(spacing: 4) {
                    Text("\(cycles) cycles")
                    Text("≈ \(formattedDuration)")
                }
                .font(.subheadline)

                Divider()

                    Text(
                        "For direct HRV measurement, please start a Mindfulness session on your Apple Watch."
                    )
                    .font(.footnote)
                    .multilineTextAlignment(.center)
//                    .lineLimit(5)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Button("OK") {
                    didAcknowledge = true
                    onAcknowledge()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    private var formattedDuration: String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes)m \(seconds)s"
    }
}

#Preview("Watch · Pre Session") {
    WatchPreSessionView(
        cycles: 4,
        totalSeconds: 240,
        onAcknowledge: {
            print("Acknowledged")
        }
    )
}

