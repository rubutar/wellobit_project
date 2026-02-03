//
//  TabRouter.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 02/01/26.
//

import SwiftUI


final class TabRouter {
    private let progressStore: ProgressStore

    init() {
        let progressRepository = LocalBreathingProgressRepository()
        self.progressStore = ProgressStore(repository: progressRepository)
    }
    

    func makeHome() -> some View {
        let sleepVM = makeSleepViewModel()
        return HomeView(
            viewModel: sleepVM
        )
    }

    func makeMockHome() -> some View {
        let sleepVM = makeSleepViewModel()
        let breathingVM = makeBreathingPlayerViewModel()
        return MockHomeView(
            viewModel: sleepVM,
            breathingViewModel: breathingVM
        )
    }

    // MARK: - LIBRARY LIST

    func makeListLibrary() -> some View {

        let libraryRepo = MockLibraryBreathingRepository()
        let breathingRepo = LocalBreathingRepository()

        let useCase = GetLibraryBreathingSessionsUseCase(
            repository: libraryRepo
        )

        let listVM = LibraryListViewModel(
            getSessionsUseCase: useCase,
            breathingRepository: breathingRepo
        )

        return LibraryListView(
            viewModel: listVM,
            makeLibrary: { [weak self] in
                guard let self else {
                    return AnyView(EmptyView())
                }
                return AnyView(self.makeLibrary())
            }
        )
    }

    func makeLibrary() -> some View {

        let breathingRepo = LocalBreathingRepository()

        let libraryVM = LibraryViewModel(
            repository: breathingRepo,
            initial: breathingRepo.load()
        )

        let sceneVM = SceneSettingsViewModel(
            repository: LocalBreathingSceneRepository()
        )

        let playerVM = BreathingPlayerViewModel(
            libraryViewModel: libraryVM,
            sceneSettingsViewModel: sceneVM,
            progressStore: progressStore   // ✅ SAME INSTANCE
        )

        return LibraryView(
            libraryViewModel: libraryVM,
            sceneSettingsViewModel: sceneVM,
            playerViewModel: playerVM
        )
    }
    
    func makeProgress() -> some View {
        ProgressScreenView(progressStore: progressStore)
    }



    // MARK: - SLEEP
    func makeSleep() -> some View {
        let sleepVM = makeSleepViewModel()
        let sleepScoreVM = makeSleepScoreViewModel()
        return SleepView(
            viewModel: sleepVM,
            sleepScoreVM: sleepScoreVM
        )
    }

    // MARK: - PRIVATE BUILDERS
    private func makeBreathingPlayerViewModel() -> BreathingPlayerViewModel {

        let repo = LocalBreathingRepository()

        let libraryVM = LibraryViewModel(
            repository: repo,
            initial: repo.load()
        )

        let sceneVM = SceneSettingsViewModel(
            repository: LocalBreathingSceneRepository()
        )

        return BreathingPlayerViewModel(
            libraryViewModel: libraryVM,
            sceneSettingsViewModel: sceneVM,
            progressStore: progressStore
        )
    }

    private func makeSleepViewModel() -> SleepViewModel {

        let sleepRepository = HealthKitSleepRepository()

        return SleepViewModel(
            fetchSleepUseCase: FetchSleepSession(repository: sleepRepository),
            fetchSleepStagesUseCase: FetchSleepStages(repository: sleepRepository),
            fetchSleepHistoryUseCase: FetchSleepHistory(repository: sleepRepository),
            fetchSleepAveragesUseCase: FetchSleepAverages(repository: sleepRepository)
        )
    }

    private func makeSleepScoreViewModel() -> SleepScoreViewModel {

        let sleepRepository = HealthKitSleepRepository()
        let vitalsRepository = HealthKitVitalsRepository()

        let inputBuilder = SleepScoreInputBuilder(
            sleepRepository: sleepRepository,
            vitalsRepository: vitalsRepository
        )

        return SleepScoreViewModel(inputBuilder: inputBuilder)
    }
}
