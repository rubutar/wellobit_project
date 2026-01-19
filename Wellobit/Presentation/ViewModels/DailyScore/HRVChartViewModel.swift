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
    
    // Existing SDNN data
    @Published var sdnnPoints: [HRVPoint] = []
    
    // NEW: RMSSD data
    @Published var rmssdPoints: [HRVPoint] = []
    
    @Published var heartRateSamples: [HeartRateSample] = []
    

    @Published var isEmpty = false
    @Published var dailyScore: Int = 0
    @Published var scoreMessage: String = ""
    @Published var interpretation: HRVInterpretation?



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

            let baselineAvgRMSSD = dailyAverage(of: rmssdBase)
            let baselineAvgSDNN = dailyAverage(of: sdnnBase)

            let baselineAvgRHR = rhrBase.isEmpty
                ? 0
                : rhrBase.reduce(0, +) / Double(rhrBase.count)

            self.dailyScore = calculateScoreUseCase.execute(
                todayRMSSD: avgRMSSD,
                baselineRMSSD: baselineAvgRMSSD,
                todaySDNN: avgSDNN,
                baselineSDNN: baselineAvgSDNN,
                todayRHR: rhrResult ?? 0,
                baselineRHR: baselineAvgRHR
            )
            self.scoreMessage = interpretScoreUseCase.execute(score: self.dailyScore)


        } catch {
            print("Error loading HRV:", error.localizedDescription)
        }
    }
    private func dailyAverage(of points: [HRVPoint]) -> Double {
        guard !points.isEmpty else { return 0 }
        return points.map { $0.value }.reduce(0, +) / Double(points.count)
    }
    
//    func updateScoreMessage() {
//        let input = HRVInterpretationInput(
//            rmssdToday: average(of: rmssdPoints),
//            rmssdBaseline: average(of: baselineRMSSD),
//            sdnnToday: average(of: sdnnPoints),
//            sdnnBaseline: average(of: baselineSDNN),
//            restingHR: todayRHR!,
//            hrBaseline: averageRHR(baselineRHR),
//            undefinedDaysStreak: 0,
//            occurredDuringSleep: true,
//            occurredDuringWaking: false,
//            repeatedWithin24h: false
//        )
//
//        let result = interpretScoreUseCase.execute(score: input)
//        self.scoreMessage = result.message
//    }

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
