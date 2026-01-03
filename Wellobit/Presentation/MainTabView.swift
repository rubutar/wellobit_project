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

            router.makeLibrary()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
        }
    }
}
