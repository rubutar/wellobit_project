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
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.dataMode, dataMode)
                .preferredColorScheme(.light)
        }
    }
}

extension EnvironmentValues {
    var dataMode: DataMode {
        get { self[DataModeKey.self] }
        set { self[DataModeKey.self] = newValue }
    }
}
