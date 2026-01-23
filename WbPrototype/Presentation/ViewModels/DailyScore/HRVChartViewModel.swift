//
//  HRVChartViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 17/01/26.
//

import Foundation
import Combine

@MainActor
final class HRVChartViewModel: ObservableObject {

    @Published var todayRHR: Double? = nil
    @Published var baselineRHR: [Double] = []

    @Published var baselineRMSSD: [HRVPoint] = []
    @Published var baselineSDNN: [HRVPoint] = []
    
    @Published var sdnnPoints: [HRVPoint] = []
    @Published var rmssdPoints: [HRVPoint] = []
    
    @Published var heartRateSamples: [HeartRateSample] = []
    
    @Published var isEmpty = false
    @Published var dailyScore: Int = 0
    @Published var currentScore: Int = 0
    @Published var scoreMessage: String = ""
    @Published var scoreLabel: String = ""
    @Published var interpretation: HRVInterpretation?
    @Published var currentInterpretation: HRVInterpretation?

    
    @Published private(set) var avgRMSSD: Double = 0
    @Published private(set) var avgSDNN: Double = 0
    @Published private(set) var currentRMSSD: Double = 0
    @Published private(set) var currentSDNN: Double = 0
    @Published private(set) var baselineRMSSDValue: Double = 0
    @Published private(set) var baselineRMSSDValueof: Double = 0
    @Published private(set) var baselineSDNNValue: Double = 0
    @Published private(set) var currentRHRValue: Double = 0
    @Published private(set) var baselineAvgRHR: Double = 0


    
    private let fetchSDNNUseCase: FetchTodayHRVUseCase
    private let fetchRMSSDUseCase: FetchTodayRMSSDUseCase
    private let fetch30DayRMSSDUseCase: FetchLast30DaysRMSSDUseCase
    private let fetch30DaySDNNUseCase: FetchLast30DaysSDNNUseCase
    private let fetchRHRUseCase: FetchTodayRHRUseCase
    private let fetch60DayRHRUseCase: FetchLast60DaysRHRUseCase
    private let fetchHeartRateUseCase: FetchTodayHeartRateSamplesUseCase
    private let calculateScoreUseCase: CalculateDailyScoreUseCase
    private let interpretScoreUseCase: InterpretDailyScoreUseCase
    private let interpretHRVUseCase: InterpretHRVUseCase

    init(
        fetchSDNNUseCase: FetchTodayHRVUseCase,
        fetchRMSSDUseCase: FetchTodayRMSSDUseCase,
        fetch30DaySDNNUseCase: FetchLast30DaysSDNNUseCase,
        fetch30DayRMSSDUseCase: FetchLast30DaysRMSSDUseCase,
        fetchRHRUseCase: FetchTodayRHRUseCase,
        fetch60DayRHRUseCase: FetchLast60DaysRHRUseCase,
        fetchHeartRateUseCase: FetchTodayHeartRateSamplesUseCase,
        calculateScoreUseCase: CalculateDailyScoreUseCase,
        interpretScoreUseCase: InterpretDailyScoreUseCase,
        interpretHRVUseCase: InterpretHRVUseCase

    ) {
        self.fetchSDNNUseCase = fetchSDNNUseCase
        self.fetchRMSSDUseCase = fetchRMSSDUseCase
        self.fetch30DaySDNNUseCase = fetch30DaySDNNUseCase
        self.fetch30DayRMSSDUseCase = fetch30DayRMSSDUseCase
        self.fetchRHRUseCase = fetchRHRUseCase
        self.fetch60DayRHRUseCase = fetch60DayRHRUseCase
        self.fetchHeartRateUseCase = fetchHeartRateUseCase
        self.calculateScoreUseCase = calculateScoreUseCase
        self.interpretScoreUseCase = interpretScoreUseCase
        self.interpretHRVUseCase = interpretHRVUseCase

    }


    func load(startDate: Date, endDate: Date) async {

        async let hr = fetchHeartRateUseCase.execute(
            startDate: startDate,
            endDate: endDate
        )

        self.heartRateSamples = (try? await hr) ?? []
        
        do {
            // Run core queries in parallel
            async let todaySDNN = fetchSDNNUseCase.execute()
            async let todayRMSSD = fetchRMSSDUseCase.execute()
            async let todayRHR = fetchRHRUseCase.execute()

            async let baselineSDNN = fetch30DaySDNNUseCase.execute()
            async let baselineRMSSD = fetch30DayRMSSDUseCase.execute()
            async let rhrBaseline = fetch60DayRHRUseCase.execute()

            let (sdnnResult,
                 rmssdResult,
                 rhrResult,
                 sdnnBase,
                 rmssdBase,
                 rhrBase) = try await (
                    todaySDNN,
                    todayRMSSD,
                    todayRHR,
                    baselineSDNN,
                    baselineRMSSD,
                    rhrBaseline
                 )

            // Assign results
            self.sdnnPoints = sdnnResult
            self.rmssdPoints = rmssdResult

            self.baselineSDNN = sdnnBase
            self.baselineRMSSD = rmssdBase

            self.todayRHR = rhrResult
            self.baselineRHR = rhrBase

            self.isEmpty = sdnnResult.isEmpty && rmssdResult.isEmpty
            
            let avgRMSSD = dailyAverage(of: rmssdResult)
            let avgSDNN = dailyAverage(of: sdnnResult)
            
            let currentRMSSD = latestValue(of: rmssdResult)
            let currentSDNN = latestValue(of: sdnnResult)

            let baselineAvgRMSSD = baselineAverage(rmssdBase)
            let baselineAvgSDNN = baselineAverage(sdnnBase)

            let baselineAvgRHR = baselineAverage(rhrBase)
            let currentRHR = rhrResult ?? 0


//            let baselineAvgRMSSDof = dailyAverage(of: rmssdBase)
//            let baselineAvgSDNN = dailyAverage(of: sdnnBase)

//            let baselineAvgRHR = rhrBase.isEmpty
//                ? 0
//                : rhrBase.reduce(0, +) / Double(rhrBase.count)

            self.currentScore = calculateScoreUseCase.execute(
                todayRMSSD: currentRMSSD,
                baselineRMSSD: baselineAvgRMSSD,
                todaySDNN: currentSDNN,
                baselineSDNN: baselineAvgSDNN,
                todayRHR: rhrResult ?? 0,
                baselineRHR: baselineAvgRHR
            )
            
            self.dailyScore = calculateScoreUseCase.execute(
                todayRMSSD: avgRMSSD,
                baselineRMSSD: baselineAvgRMSSD,
                todaySDNN: avgSDNN,
                baselineSDNN: baselineAvgSDNN,
                todayRHR: rhrResult ?? 0,
                baselineRHR: baselineAvgRHR
            )

            
//            print("RMMSD = \(avgRMSSD)")
//            print("baselineRMSSD = \(baselineAvgRMSSD)")
            self.scoreMessage = interpretScoreUseCase.execute(score: self.dailyScore)
            let currentInterpretationInput = HRVInterpretationInput(
                rmssdToday: currentRMSSD,
                rmssdBaseline: baselineAvgRMSSD,
                sdnnToday: currentSDNN,
                sdnnBaseline: baselineAvgSDNN,
                restingHR: rhrResult ?? 0,
                hrBaseline: baselineAvgRHR,
                aboveBaselineTooMuchStreak: 0,
                extremeValueDaysStreak: 0,
                occurredDuringSleep: true,
                occurredDuringWaking: false,
                repeatedWithin24h: false
            )
            self.currentInterpretation = interpretHRVUseCase.execute(input: currentInterpretationInput)

            self.avgRMSSD = avgRMSSD
            self.avgSDNN = avgSDNN
            self.currentRMSSD = currentRMSSD
            self.currentSDNN = currentSDNN
            self.baselineRMSSDValue = baselineAvgRMSSD
//            self.baselineRMSSDValueof = baselineAvgRMSSDof
            self.baselineSDNNValue = baselineAvgSDNN
            self.currentRHRValue = currentRHR
            self.baselineAvgRHR = baselineAvgRHR
            
            let interpretationInput = HRVInterpretationInput(
                rmssdToday: avgRMSSD,
                rmssdBaseline: baselineAvgRMSSD,
                sdnnToday: avgSDNN,
                sdnnBaseline: baselineAvgSDNN,
                restingHR: rhrResult ?? 0,
                hrBaseline: baselineAvgRHR,
                aboveBaselineTooMuchStreak: 0,
                extremeValueDaysStreak: 0,
                occurredDuringSleep: true,
                occurredDuringWaking: false,
                repeatedWithin24h: false
            )
            self.interpretation = interpretHRVUseCase.execute(input: interpretationInput)



        } catch {
            print("Error loading HRV:", error.localizedDescription)
        }
    }
    private func dailyAverage(of points: [HRVPoint]) -> Double {
        guard !points.isEmpty else { return 0 }
        return points.map { $0.value }.reduce(0, +) / Double(points.count)
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
                parts.append("Your daily average HRV (DSNN) is higher than your baseline")
            } else if todayRMSSD < baselineRMSSD {
                parts.append("Your daily average HRV (DSNN) is lower than your baseline")
            } else {
                parts.append("Your daily average HRV (DSNN) is similar to your baseline")
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
        guard let interpretation else { return "" }

        var parts: [String] = []

        // HRV comparison
        if let todayRMSSD = rmssdPoints.latestValue,
           let baselineRMSSD = baselineRMSSD.averageValue {

            if todayRMSSD > baselineRMSSD {
                parts.append("Your current HRV (RMSSD) is higher than your baseline")
            } else if todayRMSSD < baselineRMSSD {
                parts.append("Your current HRV (RMSSD) is lower than your baseline")
            } else {
                parts.append("Your current HRV (RMSSD) is similar to your baseline")
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
}
