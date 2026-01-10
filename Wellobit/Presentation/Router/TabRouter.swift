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
    
    func makeSleep() -> some View {

        let repository = HealthKitSleepRepository()

        let fetchSleepUseCase = FetchLatestSleepSession(
            repository: repository
        )

        let fetchSleepStagesUseCase = FetchSleepStages(
            repository: repository
        )

        let fetchSleepHistoryUseCase = FetchSleepHistory(
            repository: repository
        )
        
        let fetchSleepAveragesUseCase = FetchSleepAverages(
            repository: repository
        )

        let viewModel = SleepViewModel(
            fetchSleepUseCase: fetchSleepUseCase,
            fetchSleepStagesUseCase: fetchSleepStagesUseCase,
            fetchSleepHistoryUseCase: fetchSleepHistoryUseCase,
            fetchSleepAveragesUseCase: fetchSleepAveragesUseCase
        )

        return SleepView(viewModel: viewModel)
    }

}
