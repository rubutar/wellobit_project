//
//  StressViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import Foundation
import Combine

final class StressViewModel: ObservableObject {

    @Published var stressScore: Int = 0
    @Published var stressLevel: StressLevel = .low
    @Published var zoneSummary: StressZoneSummary?
    @Published var stressTimeline: [StressTimelinePoint] = []



    private let stressSummaryUseCase: StressSummaryUseCase
    private let zoneBreakdownUseCase: StressZoneBreakdownUseCase
    private let stressTimelineUseCase: StressTimelineUseCase


    init() {
        let fetchHRV = FetchHRVLast24HoursUseCase()

        self.stressSummaryUseCase = StressSummaryUseCase(
            fetchHRVUseCase: fetchHRV
        )

        self.zoneBreakdownUseCase = StressZoneBreakdownUseCase(
            fetchHRVUseCase: fetchHRV
        )

        self.stressTimelineUseCase = StressTimelineUseCase(
            fetchHRVUseCase: fetchHRV
        )
    }


    func load(for date: Date) {
        stressSummaryUseCase.execute(for: date) { [weak self] score, level in
            DispatchQueue.main.async {
                self?.stressScore = score
                self?.stressLevel = level
            }
        }

        zoneBreakdownUseCase.execute(for: date) { [weak self] summary in
            DispatchQueue.main.async {
                self?.zoneSummary = summary
            }
        }

        stressTimelineUseCase.execute(for: date) { [weak self] timeline in
            DispatchQueue.main.async {
                self?.stressTimeline = timeline
            }
        }
    }

}
