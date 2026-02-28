//
//  MainTabView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import SwiftUI



struct MainTabView: View {
    private let router = TabRouter()
    
    

    var body: some View {
        TabView {
            router.makeHome()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
//            router.makeMockHome()
//                .tabItem {
//                    Label("Sandbox", systemImage: "apple.image.playground")
//                }
            router.makeListLibrary()
                .tabItem {
                    Label("Library", systemImage: "book.circle")
                }
            router.makeStretchSession()
                .tabItem {
                    Label("Stretch", systemImage: "figure.cooldown")
                }
            router.makeProgress()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar")
                }
            router.makeSleep()
                .tabItem {
                    Label("Sleep", systemImage: "powersleep")
                }
        }
    }
}

