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
    @Published var rhrStressTimeline: [RHRStressPoint] = []




    private let stressSummaryUseCase: StressSummaryUseCase
    private let zoneBreakdownUseCase: StressZoneBreakdownUseCase
    private let stressTimelineUseCase: StressTimelineUseCase
    private let buildRHRStressTimelineUseCase = BuildRHRStressTimelineUseCase()



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
        
        let endDate = Calendar.current.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: date
        ) ?? date

        let startDate = Calendar.current.date(
            byAdding: .hour,
            value: -24,
            to: endDate
        )!

        let baselineRHR = 60.0

        buildRHRStressTimelineUseCase.execute(
            startDate: startDate,
            endDate: endDate,
            baselineRHR: baselineRHR
        ) { [weak self] points in
            DispatchQueue.main.async {
                print("🫀 RHR points count:", points.count)
                self?.rhrStressTimeline = points
            }
        }
    }
}
