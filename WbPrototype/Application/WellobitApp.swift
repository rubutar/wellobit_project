//
//  WellobitApp.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 04/12/25.
//

import SwiftUI

enum DataMode {
    case real
    case mock
}

private struct DataModeKey: EnvironmentKey {
    static let defaultValue: DataMode = .real
}

@main
struct WellobitApp: App {
    @State private var dataMode: DataMode = .real

    // 🔥 LONG-LIVED OBJECTS (created ONCE)
    private let progressStore = ProgressStore(
        repository: LocalBreathingProgressRepository()
    )

    private let badgeProgressVM = BadgeProgressViewModel()

    init() {
        UserDefaults.standard.register(
            defaults: [RestKeys.isResting: true]
        )
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                // ✅ Custom environment value
                .environment(\.dataMode, dataMode)

                // ✅ Global EnvironmentObjects
                .environmentObject(progressStore)
                .environmentObject(badgeProgressVM)

                .preferredColorScheme(.light)
        }    }
}

extension EnvironmentValues {
    var dataMode: DataMode {
        get { self[DataModeKey.self] }
        set { self[DataModeKey.self] = newValue }
    }
}
