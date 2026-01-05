//
//  TabRouter.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import SwiftUI

final class TabRouter {
    
    func makeHome() -> some View {
//        let vm = HomeViewModel()
        return HomeView()
    }

    func makeLibrary() -> some View {
        let repo = LocalBreathingRepository()
        let initial = repo.load()
        
        let vm = LibraryViewModel(
            repository: repo,
            initial: initial
        )
        return LibraryView(viewModel: vm)
    }
}
