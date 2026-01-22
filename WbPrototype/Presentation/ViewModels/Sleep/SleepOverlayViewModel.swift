//
//  SleepOverlayViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import Foundation
import Combine

@MainActor
final class SleepOverlayViewModel: ObservableObject {

    @Published var sleepSessions: [SleepSession] = []

    private let fetchSleepUseCase: FetchSleepSessionUseCase


    init(fetchSleepUseCase: FetchSleepSessionUseCase) {
        self.fetchSleepUseCase = fetchSleepUseCase
    }

    func load(for date: Date) async {
        do {
            if let session = try await fetchSleepUseCase.execute(for: date) {
                sleepSessions = [session]
            } else {
                sleepSessions = []
            }
        } catch {
            sleepSessions = []
        }
    }
}
