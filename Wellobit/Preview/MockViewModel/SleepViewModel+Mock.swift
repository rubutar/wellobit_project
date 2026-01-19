//
//  SleepViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 19/01/26.
//

import Foundation

extension SleepViewModel {

    static func mock() -> SleepViewModel {
        let vm = SleepViewModel(
            fetchSleepUseCase: EmptyFetchSleepUseCase(),
            fetchSleepStagesUseCase: EmptyFetchSleepStagesUseCase(),
            fetchSleepHistoryUseCase: EmptyFetchSleepHistoryUseCase(),
            fetchSleepAveragesUseCase: EmptyFetchSleepAveragesUseCase()
        )
        
        vm.applyMockState()

        return vm
    }
    private func applyMockState() {
        // call internal methods only
        self.sleepSession = .mock
        self.sleepStages = SleepStage.mockStages
        self.sleepAverages = .empty
    }
}
