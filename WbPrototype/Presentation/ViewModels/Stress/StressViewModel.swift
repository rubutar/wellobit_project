//
//  StressViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import Foundation
import Combine
import HealthKit

final class StressViewModel: ObservableObject {

    @Published var stressScore: Int = 0
    @Published var stressLevel: StressLevel = .low
    @Published var zoneSummary: StressZoneSummary?
    
    @Published var stressTimeline: [StressTimelinePoint] = []
    @Published var hrStressTimeline: [HRStressPoint] = []
    @Published var modeledStressTimeline: [StressState] = []
    
    @Published private(set) var hrvAnchors: [(Date, Double)] = []
    @Published private(set) var heartRates: [(Date, Double)] = []
    
    @Published var peakStress: Double?
    @Published var peakStressDates: [Date] = []
    
    private let detectPeakPointsUseCase = DetectStressPeakPointsUseCase()
    private let computePeakStressUseCase = ComputePeakStressScoreUseCase()

    private let stressSummaryUseCase: StressSummaryUseCase
    private let zoneBreakdownUseCase: StressZoneBreakdownUseCase
    private let stressTimelineUseCase: StressTimelineUseCase
    private let buildHRStressTimelineUseCase = BuildHRStressTimelineUseCase()
    private let buildStressTimelineUseCase = BuildStressTimelineUseCase()
    private let fetchHRV: FetchHRVLast24HoursUseCase
    private let fetchHR: FetchHeartRateUseCase


    init() {
        let hrvDataSource = HealthKitHRVDataSource(
            healthStore: HKHealthStore()
        )
        
        self.fetchHRV = FetchHRVLast24HoursUseCase(
            hrvDataSource: hrvDataSource
        )

        self.fetchHR = FetchHeartRateUseCase()
        
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

    
    private func mapHRVToStress(_ hrv: Double) -> Double {
        switch hrv {
        case ...20: return 85
        case 20..<40: return 70
        case 40..<70: return 50
        case 70..<100: return 30
        default: return 20
        }
    }
    
    func load(for date: Date) async {

        stressTimeline.removeAll()
        hrStressTimeline.removeAll()
        modeledStressTimeline.removeAll()

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in

            let group = DispatchGroup()

            group.enter()
            Task { [weak self] in
                defer { group.leave() }

                do {
                    let (score, level) = try await stressSummaryUseCase.execute(for: date)
                    print("🧪 stressSummaryUseCase FINISHED")
                    self?.stressScore = score
                    self?.stressLevel = level
                } catch {
                    print("❌ stressSummaryUseCase failed:", error)
                }
            }


            group.enter()
            zoneBreakdownUseCase.execute(for: date) { [weak self] summary in
                print("🧪 zoneBreakdownUseCase FINISHED")
                self?.zoneSummary = summary
                group.leave()
            }

            group.enter()
            stressTimelineUseCase.execute(for: date) { [weak self] timeline in
                print("🧪 stressTimelineUseCase FINISHED")
                self?.stressTimeline = timeline
                group.leave()
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

            group.enter()
            buildHRStressTimelineUseCase.execute(
                startDate: startDate,
                endDate: endDate,
                baselineHR: 60
            ) { [weak self] points in
                print("🧪 buildHRStressTimelineUseCase FINISHED")
                self?.hrStressTimeline = points
                group.leave()
            }
            
            group.enter()
            group.enter()
            Task { [weak self] in
                defer { group.leave() }

                do {
                    let samples = try await fetchHRV.execute(for: date)
                    print("🧪 FetchHRV FINISHED")

                    self?.hrvAnchors = samples.map {
                        ($0.date, self?.mapHRVToStress($0.value) ?? 50)
                    }
                } catch {
                    print("❌ FetchHRV failed:", error)
                }
            }

            
            group.enter()
            fetchHR.execute(for: date) { [weak self] samples in
                self?.heartRates = samples
                print("🧪 fetchHR FINISHED")
                group.leave()
            }

            group.notify(queue: .main) {
                print("🧪 stressViewModel.load COMPLETED")

                continuation.resume()
            }
        }
    }
    
    func loadModeledStress(
        startDate: Date,
        endDate: Date,
        sleepSessions: [SleepSession]
    ) async {

        let input = BuildStressTimelineUseCase.Input(
            startDate: startDate,
            endDate: endDate,
            hrvAnchors: hrvAnchors,
            heartRates: heartRates,
            sleepSessions: sleepSessions
        )

        modeledStressTimeline = buildStressTimelineUseCase.execute(input: input)

        // 🔴 peak points (red dots)
        peakStressDates = detectPeakPointsUseCase.execute(
            states: modeledStressTimeline
        )

        // 🎯 peak stress %
        peakStress = computePeakStressUseCase.execute(
            states: modeledStressTimeline
        )

    
        
        print("""
        🧪 loadModeledStress CALLED
        start: \(startDate)
        end: \(endDate)
        HRV anchors: \(hrvAnchors.count)
        HR samples: \(heartRates.count)
        Sleep sessions: \(sleepSessions.count)
        """)

    }
}
