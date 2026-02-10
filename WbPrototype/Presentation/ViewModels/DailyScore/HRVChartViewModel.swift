//
//  HRVChartViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 17/01/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class HRVChartViewModel: ObservableObject {

    @Published var todayRHR: Double? = nil
    @Published var baselineRHR: [Double] = []

    @Published var baselineRMSSD: [HRVPoint] = []
    @Published var baselineSDNN: [HRVPoint] = []
    
    @Published var sdnnPoints: [HRVPoint] = []
    @Published var rmssdPoints: [HRVPoint] = []
    
    @Published var heartRateSamples: [HeartRateSample] = []
    
    @AppStorage(RestKeys.isResting)
    private var isResting: Bool = true
    
    @Published var isEmpty = false
    @Published var dailyScore: Int = 0
    @Published var currentScore: Int = 0
    @Published var scoreMessage: String = ""
    @Published var scoreLabel: String = ""
    @Published var interpretation: HRVInterpretation?
    @Published var currentInterpretation: HRVInterpretation?
    @Published var latestSnapshot: HRVSnapshot?
    @Published var hrBaseline7Days: Double?
    
    @Published private(set) var avgRMSSD: Double = 0
    @Published private(set) var avgSDNN: Double = 0
    @Published private(set) var currentRMSSD: Double = 0
    @Published private(set) var currentSDNN: Double = 0
    @Published private(set) var baselineRMSSDValue: Double = 0
    @Published private(set) var baselineRMSSDValueof: Double = 0
    @Published private(set) var baselineSDNNValue: Double = 0
    @Published private(set) var currentRHRValue: Double = 0
    @Published private(set) var baselineAvgRHR: Double = 0
    @Published private(set) var isUsingMockData = false
    
    private let fetchSDNNUseCase: FetchTodayHRVUseCase
    private let fetchRMSSDUseCase: FetchTodayRMSSDUseCase
    private let fetch30DayRMSSDUseCase: FetchLast30DaysRMSSDUseCase
    private let fetch30DaySDNNUseCase: FetchLast30DaysSDNNUseCase
    private let fetchRHRUseCase: FetchTodayRHRUseCase
    private let fetch60DayRHRUseCase: FetchLast60DaysRHRUseCase
    private let fetchHeartRateUseCase: FetchTodayHeartRateSamplesUseCase
    private let calculateScoreUseCase: CalculateDailyScoreUseCase
    private let calculateCurrentScoreUseCase: CalculateCurrentScoreUseCase
    private let interpretScoreUseCase: InterpretDailyScoreUseCase
    private let interpretHRVUseCase: InterpretHRVUseCase
    private let fetchLatestSnapshotUseCase: FetchLatestHRVSnapshotUseCase
    private let fetchHRBaselineUseCase: FetchHRBaselineUseCase



    init(
        fetchSDNNUseCase: FetchTodayHRVUseCase,
        fetchRMSSDUseCase: FetchTodayRMSSDUseCase,
        fetch30DaySDNNUseCase: FetchLast30DaysSDNNUseCase,
        fetch30DayRMSSDUseCase: FetchLast30DaysRMSSDUseCase,
        fetchRHRUseCase: FetchTodayRHRUseCase,
        fetch60DayRHRUseCase: FetchLast60DaysRHRUseCase,
        fetchHeartRateUseCase: FetchTodayHeartRateSamplesUseCase,
        calculateScoreUseCase: CalculateDailyScoreUseCase,
        calculateCurrentScoreUseCase: CalculateCurrentScoreUseCase,
        interpretScoreUseCase: InterpretDailyScoreUseCase,
        interpretHRVUseCase: InterpretHRVUseCase,
        fetchLatestSnapshotUseCase: FetchLatestHRVSnapshotUseCase,
        fetchHRBaselineUseCase: FetchHRBaselineUseCase

    ) {
        self.fetchSDNNUseCase = fetchSDNNUseCase
        self.fetchRMSSDUseCase = fetchRMSSDUseCase
        self.fetch30DaySDNNUseCase = fetch30DaySDNNUseCase
        self.fetch30DayRMSSDUseCase = fetch30DayRMSSDUseCase
        self.fetchRHRUseCase = fetchRHRUseCase
        self.fetch60DayRHRUseCase = fetch60DayRHRUseCase
        self.fetchHeartRateUseCase = fetchHeartRateUseCase
        self.calculateScoreUseCase = calculateScoreUseCase
        self.calculateCurrentScoreUseCase = calculateCurrentScoreUseCase
        self.interpretScoreUseCase = interpretScoreUseCase
        self.interpretHRVUseCase = interpretHRVUseCase
        self.fetchLatestSnapshotUseCase = fetchLatestSnapshotUseCase
        self.fetchHRBaselineUseCase = fetchHRBaselineUseCase
    }

    func applyMockBaselines(
        rmssd: Double,
        sdnn: Double,
        hr: Double
    ) {
        baselineRMSSDValue = rmssd
        baselineSDNNValue = sdnn
        hrBaseline7Days = hr
    }

    func applyMockSnapshot(
        rmssd: Double,
        sdnn: Double,
        hr: Double
    ) {
        let now = Date()
        latestSnapshot = HRVSnapshot(
            sdnn: HRVPoint(date: now, value: sdnn, type: .sdnn),
            rmssd: HRVPoint(date: now, value: rmssd, type: .rmssd),
            heartRate: HeartRateSample(date: now, bpm: hr)
        )
        computeCurrentMetricsFromSnapshot()
    }

//    func load(startDate: Date, endDate: Date) async {
//        
//        async let hrBaseline = fetchHRBaselineUseCase.execute(days: 7)
//
//        async let hr = fetchHeartRateUseCase.execute(
//            startDate: startDate,
//            endDate: endDate
//        )
//
//        let fetchedHR = (try? await hr) ?? []
//        if !isUsingMockData {
//            self.heartRateSamples = fetchedHR
//        }
//        self.hrBaseline7Days = try? await hrBaseline
//        
//        do {
//            // Run core queries in parallel
//            async let todaySDNN = fetchSDNNUseCase.execute()
//            async let todayRMSSD = fetchRMSSDUseCase.execute()
//            async let todayRHR = fetchRHRUseCase.execute()
//
//            async let baselineSDNN = fetch30DaySDNNUseCase.execute()
//            async let baselineRMSSD = fetch30DayRMSSDUseCase.execute()
//            async let rhrBaseline = fetch60DayRHRUseCase.execute()
//
//            let (sdnnResult,
//                 rmssdResult,
//                 rhrResult,
//                 sdnnBase,
//                 rmssdBase,
//                 rhrBase) = try await (
//                    todaySDNN,
//                    todayRMSSD,
//                    todayRHR,
//                    baselineSDNN,
//                    baselineRMSSD,
//                    rhrBaseline
//                 )
//
//            // Assign results
//            if !isUsingMockData {
//                self.sdnnPoints = sdnnResult
//            }
//            self.rmssdPoints = rmssdResult
//
//            self.baselineSDNN = sdnnBase
//            self.baselineRMSSD = rmssdBase
//
//            self.todayRHR = rhrResult
//            self.baselineRHR = rhrBase
//
//            self.isEmpty = sdnnResult.isEmpty && rmssdResult.isEmpty
//            
//            let avgRMSSD = dailyAverage(of: rmssdResult)
//            let avgSDNN = dailyAverage(of: sdnnResult)
//            
//            let currentRMSSD = latestValue(of: rmssdResult)
//            let currentSDNN = latestValue(of: sdnnResult)
//
//            let baselineAvgRMSSD = baselineAverage(rmssdBase)
//            let baselineAvgSDNN = baselineAverage(sdnnBase)
//
//            let baselineAvgRHR = baselineAverage(rhrBase)
//            let currentRHR = rhrResult ?? 0
//            
//            self.dailyScore = calculateScoreUseCase.execute(
//                todayRMSSD: avgRMSSD,
//                baselineRMSSD: baselineAvgRMSSD,
//                todaySDNN: avgSDNN,
//                baselineSDNN: baselineAvgSDNN,
//                todayRHR: rhrResult ?? 0,
//                baselineRHR: baselineAvgRHR
//            )
//
//            self.scoreMessage = interpretScoreUseCase.execute(score: self.dailyScore)
//
//            self.avgRMSSD = avgRMSSD
//            self.avgSDNN = avgSDNN
//            self.currentRMSSD = currentRMSSD
//            self.currentSDNN = currentSDNN
//            self.baselineRMSSDValue = baselineAvgRMSSD
//            self.baselineSDNNValue = baselineAvgSDNN
//            self.currentRHRValue = currentRHR
//            self.baselineAvgRHR = baselineAvgRHR
//            
//            let interpretationInput = HRVInterpretationInput(
//                hrvSamples: sdnnPoints,
//                hrSamples: heartRateSamples,
//                rmssdToday: avgRMSSD,
//                rmssdBaseline: baselineAvgRMSSD,
//                sdnnToday: avgSDNN,
//                sdnnBaseline: baselineAvgSDNN,
//                currentHR: rhrResult ?? 0,
//                hrBaseline: baselineAvgRHR,
//                aboveBaselineTooMuchStreak: 0,
//                extremeValueDaysStreak: 0,
//                occurredDuringSleep: true,
//                occurredDuringWaking: false,
//                repeatedWithin24h: false,
//                isRest: isResting
//            )
//            self.interpretation = interpretHRVUseCase.execute(input: interpretationInput)
//
//        } catch {
//            print("Error loading HRV:", error.localizedDescription)
//        }
//    }
    
    func load(startDate: Date, endDate: Date) async {

        do {
            // MARK: - Fetch in parallel (background-safe)

            async let hrBaselineTask = fetchHRBaselineUseCase.execute(days: 7)
            async let hrTask = fetchHeartRateUseCase.execute(
                startDate: startDate,
                endDate: endDate
            )

            async let todaySDNNTask = fetchSDNNUseCase.execute()
            async let todayRMSSDTask = fetchRMSSDUseCase.execute()
            async let todayRHRTask = fetchRHRUseCase.execute()

            async let baselineSDNNTask = fetch30DaySDNNUseCase.execute()
            async let baselineRMSSDTask = fetch30DayRMSSDUseCase.execute()
            async let rhrBaselineTask = fetch60DayRHRUseCase.execute()

            let fetchedHR = (try? await hrTask) ?? []
            let hrBaseline = try? await hrBaselineTask

            let (
                sdnnResult,
                rmssdResult,
                rhrResult,
                sdnnBase,
                rmssdBase,
                rhrBase
            ) = try await (
                todaySDNNTask,
                todayRMSSDTask,
                todayRHRTask,
                baselineSDNNTask,
                baselineRMSSDTask,
                rhrBaselineTask
            )

            // MARK: - Pure calculations (still background-safe)

            let avgRMSSD = dailyAverage(of: rmssdResult)
            let avgSDNN = dailyAverage(of: sdnnResult)

            let currentRMSSD = latestValue(of: rmssdResult)
            let currentSDNN = latestValue(of: sdnnResult)

            let baselineAvgRMSSD = baselineAverage(rmssdBase)
            let baselineAvgSDNN = baselineAverage(sdnnBase)

            let baselineAvgRHR = baselineAverage(rhrBase)
            let currentRHR = rhrResult ?? 0

            let dailyScore = calculateScoreUseCase.execute(
                todayRMSSD: avgRMSSD,
                baselineRMSSD: baselineAvgRMSSD,
                todaySDNN: avgSDNN,
                baselineSDNN: baselineAvgSDNN,
                todayRHR: currentRHR,
                baselineRHR: baselineAvgRHR
            )

            let scoreMessage = interpretScoreUseCase.execute(score: dailyScore)

            let interpretationInput = HRVInterpretationInput(
                hrvSamples: sdnnResult,
                hrSamples: fetchedHR,
                rmssdToday: avgRMSSD,
                rmssdBaseline: baselineAvgRMSSD,
                sdnnToday: avgSDNN,
                sdnnBaseline: baselineAvgSDNN,
                currentHR: currentRHR,
                hrBaseline: baselineAvgRHR,
                aboveBaselineTooMuchStreak: 0,
                extremeValueDaysStreak: 0,
                occurredDuringSleep: true,
                occurredDuringWaking: false,
                repeatedWithin24h: false,
                isRest: isResting
            )

            let interpretation = interpretHRVUseCase.execute(input: interpretationInput)

            // MARK: - 🔥 UI STATE UPDATE (MAIN ACTOR ONLY)

            await MainActor.run {
                if !self.isUsingMockData {
                    self.heartRateSamples = fetchedHR
                    self.sdnnPoints = sdnnResult
                }

                self.rmssdPoints = rmssdResult
                self.hrBaseline7Days = hrBaseline

                self.baselineSDNN = sdnnBase
                self.baselineRMSSD = rmssdBase
                self.todayRHR = rhrResult
                self.baselineRHR = rhrBase

                self.isEmpty = sdnnResult.isEmpty && rmssdResult.isEmpty

                self.dailyScore = dailyScore
                self.scoreMessage = scoreMessage

                self.avgRMSSD = avgRMSSD
                self.avgSDNN = avgSDNN
                self.currentRMSSD = currentRMSSD
                self.currentSDNN = currentSDNN
                self.baselineRMSSDValue = baselineAvgRMSSD
                self.baselineSDNNValue = baselineAvgSDNN
                self.currentRHRValue = currentRHR
                self.baselineAvgRHR = baselineAvgRHR

                self.interpretation = interpretation
            }

        } catch {
            print("Error loading HRV:", error.localizedDescription)
        }
    }

    
    private func dailyAverage(of points: [HRVPoint]) -> Double {
        guard !points.isEmpty else { return 0 }
        return points.map { $0.value }.reduce(0, +) / Double(points.count)
    }
    
    private func computeCurrentMetricsFromSnapshot() {
        guard
            let snapshot = latestSnapshot,
            let hrBaseline = hrBaseline7Days
        else {
            currentScore = 0
            currentInterpretation = nil
            return
        }

        let currentRMSSD = snapshot.rmssd?.value ?? 0
        let currentSDNN = snapshot.sdnn?.value ?? 0
        let currentHR = snapshot.heartRate?.bpm ?? 0

        // 1. Score
        currentScore = calculateCurrentScoreUseCase.execute(
            currentRMSSD: currentRMSSD,
            baselineRMSSD: baselineRMSSDValue,
            currentSDNN: currentSDNN,
            baselineSDNN: baselineSDNNValue,
            currentHR: currentHR,
            baselineHR: hrBaseline
        )

        let currentInterpretationInput = HRVInterpretationInput(
            hrvSamples: sdnnPoints,
            hrSamples: heartRateSamples,
            rmssdToday: currentRMSSD,
            rmssdBaseline: baselineRMSSDValue,
            sdnnToday: currentSDNN,
            sdnnBaseline: baselineSDNNValue,
            currentHR: currentHR,
            hrBaseline: hrBaseline,
            aboveBaselineTooMuchStreak: 0,
            extremeValueDaysStreak: 0,
            occurredDuringSleep: true,
            occurredDuringWaking: false,
            repeatedWithin24h: false,
            isRest: isResting
        )

        currentInterpretation = interpretHRVUseCase.execute(input: currentInterpretationInput)
    }


}

private extension HRVChartViewModel {
    
    func average(of points: [HRVPoint]) -> Double {
        guard !points.isEmpty else { return 0 }
        return points.map { $0.value }.reduce(0, +) / Double(points.count)
    }
    
    func averageRHR(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }
}

extension HRVChartViewModel {
    var detailedExplanation: String {
        guard let interpretation else { return "" }

        var parts: [String] = []

        // HRV comparison
        if let todayRMSSD = sdnnPoints.averageValue,
           let baselineRMSSD = baselineRMSSD.averageValue {

            if todayRMSSD > baselineRMSSD {
                parts.append("Your daily average HRV (SDNN) is higher than your baseline")
            } else if todayRMSSD < baselineRMSSD {
                parts.append("Your daily average HRV (SDNN) is lower than your baseline")
            } else {
                parts.append("Your daily average HRV (SDNN) is similar to your baseline")
            }
        }

        // RHR comparison
        if let todayRHR,
           !baselineRHR.isEmpty {

            let baseline = baselineRHR.reduce(0, +) / Double(baselineRHR.count)

            if todayRHR > baseline {
                parts.append("your resting heart rate is higher than your baseline")
            } else if todayRHR < baseline {
                parts.append("your resting heart rate is lower than your baseline")
            } else {
                parts.append("your resting heart rate is similar to your baseline")
            }
        }
        let factualSentence = parts.joined(separator: " and ")

        if factualSentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return interpretation.message
        } else {
            return "\(factualSentence). \(interpretation.message)"
        }
    }
    
    var currentDetailedExplanation: String {
        guard
            let snapshot = latestSnapshot
        else { return "" }
        
        var parts: [String] = []

        // HRV comparison
        if let currentRMSSD = snapshot.rmssd?.value,
           let baselineRMSSD = baselineRMSSD.averageValue {

            if currentRMSSD > baselineRMSSD {
                parts.append("Your current HRV (RMSSD) is higher than your baseline")
            } else if currentRMSSD < baselineRMSSD {
                parts.append("Your current HRV (RMSSD) is lower than your baseline")
            } else {
                parts.append("Your current HRV (RMSSD) is similar to your baseline")
            }
        }

        // RHR comparison
        if let hr = snapshot.heartRate?.bpm,
           let hrBaseline = hrBaseline7Days {

            if hr > hrBaseline {
                parts.append("your current heart rate is higher than your baseline")
            } else if hr < hrBaseline {
                parts.append("your current heart rate is lower than your baseline")
            } else {
                parts.append("your current heart rate is similar to your baseline")
            }
        }
        let factualSentence = parts.joined(separator: " and ")

        if factualSentence.isEmpty {
            return interpretation?.message ?? ""
        } else if let interpretation {
            return "\(factualSentence). \(interpretation.message)"
        } else {
            return factualSentence
        }
    }
    
    private func latestValue(of points: [HRVPoint]) -> Double {
        points
            .sorted { $0.date < $1.date }
            .last?
            .value ?? 0
    }

    private func baselineAverage(_ values: [HRVPoint]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.map { $0.value }.reduce(0, +) / Double(values.count)
    }

    private func baselineAverage(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    func loadLatestSnapshot() async {
        do {
            latestSnapshot = try await fetchLatestSnapshotUseCase.execute()
            computeCurrentMetricsFromSnapshot()
        } catch {
            latestSnapshot = nil
            currentScore = 0
            print("Failed to load HRV snapshot:", error)
        }
    }
    func runInterpretation() {
        let input = HRVInterpretationInput(
            hrvSamples: sdnnPoints,
            hrSamples: heartRateSamples,
            rmssdToday: currentRMSSD,
            rmssdBaseline: baselineRMSSDValue,
            sdnnToday: currentSDNN,
            sdnnBaseline: baselineSDNNValue,
            currentHR: currentRHRValue,
            hrBaseline: hrBaseline7Days ?? 0,
            aboveBaselineTooMuchStreak: 0,
            extremeValueDaysStreak: 0,
            occurredDuringSleep: true,
            occurredDuringWaking: false,
            repeatedWithin24h: false,
            isRest: isResting
        )
        interpretation = interpretHRVUseCase.execute(input: input)
    }

}



extension HRVChartViewModel {
    func applyMockHeartRateSamples(_ samples: [HeartRateSample]) {
        isUsingMockData = true
        heartRateSamples = samples
    }


    func applyMockHRVPoints(_ points: [HRVPoint]) {
        isUsingMockData = true
        sdnnPoints = points
    }
}

