////
////  HomeViewMocks.swift
////  Wellobit
////
////  Created by Rudi Butarbutar on 18/01/26.
////
//
//#if DEBUG
//
//import Foundation
//
//// MARK: - Dummy HRV Use Cases (Today)
//
//struct DummyFetchTodayRMSSDUseCase: FetchTodayRMSSDUseCase {
//    func execute() async throws -> [HRVPoint] {
//        []
//    }
//}
//
//struct DummyFetchTodaySDNNUseCase: FetchTodayHRVUseCase {
//    func execute() async throws -> [HRVPoint] {
//        []
//    }
//}
//
//// MARK: - Dummy HRV Baseline Use Cases (30 Days)
//
//struct DummyFetchLast30DaysRMSSDUseCase: FetchLast30DaysRMSSDUseCase {
//    func execute() async throws -> [HRVPoint] {
//        []
//    }
//}
//
//struct DummyFetchLast30DaysSDNNUseCase: FetchLast30DaysSDNNUseCase {
//    func execute() async throws -> [HRVPoint] {
//        []
//    }
//}
//
//// MARK: - Dummy RHR Use Cases
//
//struct DummyFetchTodayRHRUseCase: FetchTodayRHRUseCase {
//    func execute() async throws -> Double {
//        61
//    }
//}
//
//struct DummyFetchLast60DaysRHRUseCase: FetchLast60DaysRHRUseCase {
//    func execute() async throws -> [Double] {
//        [58, 59, 60]
//    }
//}
//
//// MARK: - Dummy Daily Score Use Cases
//
//struct DummyCalculateDailyScoreUseCase: CalculateDailyScoreUseCase {
//    func execute(_: DailyScoreInput) -> Int {
//        42
//    }
//}
//
//struct DummyInterpretDailyScoreUseCase: InterpretDailyScoreUseCase {
//    func execute(_: Int) -> String {
//        "Pay Attention"
//    }
//}
//
//// MARK: - HRVChartViewModel Preview Factory
//
//extension HRVChartViewModel {
//
//    static func previewMock() -> HRVChartViewModel {
//
//        let vm = HRVChartViewModel(
//            fetchSDNNUseCase: DummyFetchTodaySDNNUseCase(),
//            fetchRMSSDUseCase: DummyFetchTodayRMSSDUseCase(),
//            fetch30DaySDNNUseCase: DummyFetchLast30DaysSDNNUseCase(),
//            fetch30DayRMSSDUseCase: DummyFetchLast30DaysRMSSDUseCase(),
//            fetchRHRUseCase: DummyFetchTodayRHRUseCase(),
//            fetch60DayRHRUseCase: DummyFetchLast60DaysRHRUseCase(),
//            calculateScoreUseCase: DummyCalculateDailyScoreUseCase(),
//            interpretScoreUseCase: DummyInterpretDailyScoreUseCase()
//        )
//
//        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: Date())
//
//        // RMSSD samples (including spike)
//        vm.rmssdPoints = [
//            HRVPoint(
//                date: calendar.date(byAdding: .hour, value: 1, to: startOfDay)!,
//                value: 32
//            ),
//            HRVPoint(
//                date: calendar.date(byAdding: .hour, value: 6, to: startOfDay)!,
//                value: 75
//            ),
//            HRVPoint(
//                date: calendar.date(byAdding: .hour, value: 10, to: startOfDay)!,
//                value: 40
//            )
//        ]
//
//        // SDNN samples
//        vm.sdnnPoints = [
//            HRVPoint(
//                date: calendar.date(byAdding: .hour, value: 1, to: startOfDay)!,
//                value: 55
//            ),
//            HRVPoint(
//                date: calendar.date(byAdding: .hour, value: 6, to: startOfDay)!,
//                value: 90
//            ),
//            HRVPoint(
//                date: calendar.date(byAdding: .hour, value: 10, to: startOfDay)!,
//                value: 60
//            )
//        ]
//
//        // Baselines
//        vm.baselineRMSSD = [
//            HRVPoint(date: startOfDay, value: 32)
//        ]
//
//        vm.baselineSDNN = [
//            HRVPoint(date: startOfDay, value: 55)
//        ]
//
//        // RHR
//        vm.todayRHR = 61
//        vm.baselineRHR = [58, 59, 60]
//
//        // Daily score
//        vm.dailyScore = 42
//        vm.scoreMessage = "Pay Attention"
//
//        return vm
//    }
//}
//
//// MARK: - SleepViewModel Preview Factory
//
//extension SleepViewModel {
//
//    static func previewMock() -> SleepViewModel {
//        let vm = SleepViewModel(selectedDate: Date())
//
//        let calendar = Calendar.current
//        let start = calendar.startOfDay(for: Date())
//        let end = calendar.date(byAdding: .hour, value: 7, to: start)!
//
//        vm.sleepSession = SleepSession(
//            startDate: start,
//            endDate: end,
//            duration: end.timeIntervalSince(start)
//        )
//
//        return vm
//    }
//}
//
//#endif
