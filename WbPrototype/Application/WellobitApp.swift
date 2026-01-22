//
//  WellobitApp.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 04/12/25.
//

import SwiftUI

@main
struct WellobitApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light)
        }
    }
}
