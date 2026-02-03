//
//  ProgressViewModel.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 02/02/26.
//


import Foundation
import SwiftUI
import Combine

final class ProgressViewModel: ObservableObject {

    @ObservedObject var progressStore: ProgressStore

    init(progressStore: ProgressStore) {
        self.progressStore = progressStore
        print("📊 ProgressViewModel uses ProgressStore:",
              ObjectIdentifier(progressStore))
    }

    var completedSessionsToday: Int {
        progressStore.progress.completedSessions
    }

    var badgesToday: Int {
        progressStore.progress.badges
    }
}


