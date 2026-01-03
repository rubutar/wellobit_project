//
//  WellobitWatchApp.swift
//  WellobitWatch Watch App
//
//  Created by Rudi Butarbutar on 04/12/25.
//

import SwiftUI

@main
struct WellobitWatch_Watch_AppApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self)
    var extensionDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(extensionDelegate.workoutViewModel)
                .onAppear {
                    extensionDelegate.workoutViewModel.requestAuthorization()
                }

        }
    }
}

