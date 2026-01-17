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

    @Published var isEmpty = false

    private let fetchSDNNUseCase: FetchTodayHRVUseCase
    private let fetchRMSSDUseCase: FetchTodayRMSSDUseCase
    private let fetch30DayRMSSDUseCase: FetchLast30DaysRMSSDUseCase
    private let fetch30DaySDNNUseCase: FetchLast30DaysSDNNUseCase
    private let fetchRHRUseCase: FetchTodayRHRUseCase
    private let fetch60DayRHRUseCase: FetchLast60DaysRHRUseCase




    init(
        fetchSDNNUseCase: FetchTodayHRVUseCase,
        fetchRMSSDUseCase: FetchTodayRMSSDUseCase,
        fetch30DaySDNNUseCase: FetchLast30DaysSDNNUseCase,
        fetch30DayRMSSDUseCase: FetchLast30DaysRMSSDUseCase,
        fetchRHRUseCase: FetchTodayRHRUseCase,
        fetch60DayRHRUseCase: FetchLast60DaysRHRUseCase


    ) {
        self.fetchSDNNUseCase = fetchSDNNUseCase
        self.fetchRMSSDUseCase = fetchRMSSDUseCase
        self.fetch30DaySDNNUseCase = fetch30DaySDNNUseCase
        self.fetch30DayRMSSDUseCase = fetch30DayRMSSDUseCase
        self.fetchRHRUseCase = fetchRHRUseCase
        self.fetch60DayRHRUseCase = fetch60DayRHRUseCase

    }


    func load() async {

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

        } catch {
            print("Error loading HRV:", error.localizedDescription)
        }
    }


}
