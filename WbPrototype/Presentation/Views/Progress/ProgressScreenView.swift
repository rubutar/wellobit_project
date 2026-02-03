//
//  ProgressView.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 02/02/26.
//

//import SwiftUI

//struct ProgressScreenView: View {
//
//    @ObservedObject var viewModel: ProgressViewModel
//    var body: some View {
//        VStack(spacing: 24) {
//            Text("Progress")
//                .font(.largeTitle)
//                .bold()
//
//            Text("Sessions today")
//            Text("\(viewModel.completedSessionsToday)")
//                .font(.system(size: 48, weight: .bold))
//
//            Text("Badges today")
//            Text("🏅 \(viewModel.badgesToday)")
//                .font(.system(size: 48))
//
//            Spacer()
//        }
//        .padding()
//    }
//}


import SwiftUI

struct ProgressScreenView: View {

    @ObservedObject var progressStore: ProgressStore

    var body: some View {
        VStack(spacing: 24) {
            Text("Progress")
                .font(.largeTitle)
                .bold()

            Text("Sessions today")
            Text("\(progressStore.progress.completedSessions)")
                .font(.system(size: 48, weight: .bold))

            Text("Badges today")
            Text("🏅 \(progressStore.progress.badges)")
                .font(.system(size: 48))

            Spacer()
        }
        .padding()
        .onChange(of: progressStore.progress) { value in
            print("🔁 Progress UI updated:", value)
        }
    }
}
