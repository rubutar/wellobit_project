//
//  TabRouter.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import SwiftUI

final class TabRouter {
    
    func makeHome() -> some View {

        // Repositories
        let sleepRepository = HealthKitSleepRepository()
        let vitalsRepository = HealthKitVitalsRepository()

        // Sleep use cases
        let fetchSleepUseCase = FetchSleepSession(
            repository: sleepRepository
        )

        let fetchSleepStagesUseCase = FetchSleepStages(
            repository: sleepRepository
        )

        let fetchSleepHistoryUseCase = FetchSleepHistory(
            repository: sleepRepository
        )

        let fetchSleepAveragesUseCase = FetchSleepAverages(
            repository: sleepRepository
        )

        // Sleep ViewModel
        let sleepViewModel = SleepViewModel(
            fetchSleepUseCase: fetchSleepUseCase,
            fetchSleepStagesUseCase: fetchSleepStagesUseCase,
            fetchSleepHistoryUseCase: fetchSleepHistoryUseCase,
            fetchSleepAveragesUseCase: fetchSleepAveragesUseCase
        )

        // Sleep score wiring
        let sleepScoreInputBuilder = SleepScoreInputBuilder(
            sleepRepository: sleepRepository,
            vitalsRepository: vitalsRepository
        )

        let sleepScoreViewModel = SleepScoreViewModel(
            inputBuilder: sleepScoreInputBuilder
        )

        return HomeView(
            viewModel: sleepViewModel
        )
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

        // Repositories
        let sleepRepository = HealthKitSleepRepository()
        let vitalsRepository = HealthKitVitalsRepository()

        // Sleep use cases
        let fetchSleepUseCase = FetchSleepSession(
            repository: sleepRepository
        )

        let fetchSleepStagesUseCase = FetchSleepStages(
            repository: sleepRepository
        )

        let fetchSleepHistoryUseCase = FetchSleepHistory(
            repository: sleepRepository
        )

        let fetchSleepAveragesUseCase = FetchSleepAverages(
            repository: sleepRepository
        )

        // Sleep ViewModel
        let sleepViewModel = SleepViewModel(
            fetchSleepUseCase: fetchSleepUseCase,
            fetchSleepStagesUseCase: fetchSleepStagesUseCase,
            fetchSleepHistoryUseCase: fetchSleepHistoryUseCase,
            fetchSleepAveragesUseCase: fetchSleepAveragesUseCase
        )

        // Sleep score wiring
        let sleepScoreInputBuilder = SleepScoreInputBuilder(
            sleepRepository: sleepRepository,
            vitalsRepository: vitalsRepository
        )

        let sleepScoreViewModel = SleepScoreViewModel(
            inputBuilder: sleepScoreInputBuilder
        )

        return SleepView(
            viewModel: sleepViewModel,
            sleepScoreVM: sleepScoreViewModel
        )
    }


}
