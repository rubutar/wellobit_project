//
//  MockHRVChartViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 19/01/26.
//

import SwiftUI

extension HRVChartViewModel {
    static func mock() -> HRVChartViewModel {
        let hrValues = (0..<144).map { _ in
            Int.random(in: 15...80)
        }
        let rmssdValues: [Double] = [
            42, 40, 39, 38, 50, 36,
            38, 40, 40,
            45, 48, 50,
            47, 44, 42,
            46, 50, 52,
            49, 47, 45, 44, 43, 50
        ]
        let sdnnValues: [Double] = [
            28, 27, 27, 26, 26, 25,
            26, 27, 28,
            30, 32, 33,
            31, 30, 29,
            30, 32, 34,
            33, 32, 31, 30, 29, 28
        ]

        let vm = HRVChartViewModel(
            fetchSDNNUseCase: EmptySDNNUseCase(),
            fetchRMSSDUseCase: EmptyRMSSDUseCase(),
            fetch30DaySDNNUseCase: Empty30DaySDNNUseCase(),
            fetch30DayRMSSDUseCase: Empty30DayRMSSDUseCase(),
            fetchRHRUseCase: EmptyRHRUseCase(),
            fetch60DayRHRUseCase: EmptyRHRHistoryUseCase(),
            fetchHeartRateUseCase: EmptyHeartRateUseCase(),
            calculateScoreUseCase: CalculateDailyScoreUseCaseImpl(),
            interpretScoreUseCase: InterpretDailyScoreUseCaseImpl(),
            interpretHRVUseCase: InterpretHRVUseCaseImpl()
        )
        vm.rmssdPoints = HRVPoint.mockRMSSDHourly(
            values: rmssdValues)
        vm.sdnnPoints = HRVPoint.mockSDNN(
            values: sdnnValues)
        vm.baselineRMSSD = HRVPoint.mockRMSSDHourly(values: [32, 34, 36, 38])
        vm.baselineSDNN = HRVPoint.mockSDNN(values: [48, 49, 50, 52])
        vm.heartRateSamples = MockHeartRateSample.samples(values: hrValues)
        vm.todayRHR = 61
        vm.baselineRHR = [58, 59, 60, 62]
        vm.dailyScore = 72
        let input = HRVInterpretationInput(
//            rmssdToday: rmssdValues.reduce(0, +) / Double(rmssdValues.count),
            rmssdToday: rmssdValues.max() ?? 0,
            rmssdBaseline: [32, 34, 36, 38].reduce(0, +) / 4,
            sdnnToday: sdnnValues.reduce(0, +) / Double(sdnnValues.count),
            sdnnBaseline: [48, 49, 50, 52].reduce(0, +) / 4,
            restingHR: 50,
            hrBaseline: [58, 59, 60, 62].reduce(0, +) / 4,
            aboveBaselineTooMuchStreak: 2,
            extremeValueDaysStreak: 0,
            occurredDuringSleep: true,
            occurredDuringWaking: false,
            repeatedWithin24h: false
        )

        let interpretation = InterpretHRVUseCaseImpl().execute(input: input)

        vm.interpretation = interpretation
        vm.scoreMessage = interpretation.message
        return vm
    }
}


#Preview {
    PreviewHomeView(
        viewModel: SleepViewModel.mock(),
        hrvViewModel: HRVChartViewModel.mock()
    )
}

