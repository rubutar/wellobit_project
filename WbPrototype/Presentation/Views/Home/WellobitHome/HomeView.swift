//
//  SleepView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//
import SwiftUI
import HealthKit

struct HomeView: View {
    
    
    @State private var showWellbeingInfo = false
    
    @StateObject var viewModel: SleepViewModel
    @StateObject private var stressViewModel = StressViewModel()
    @StateObject private var hrvViewModel: HRVChartViewModel

    init(viewModel: SleepViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        let dataSource = HealthKitHRVDataSource(
            healthStore: HKHealthStore()
        )
        let sdnnUseCase = FetchTodayHRVUseCaseImpl(
            hrvDataSource: dataSource
        )
        let rmssdUseCase = FetchTodayRMSSDUseCaseImpl(
            hrvDataSource: dataSource
        )
        let hrDataSource = HealthKitHeartRateDataSource(
            healthStore: HKHealthStore()
        )
        let fetchHRUseCase = FetchTodayHeartRateSamplesUseCaseImpl(
            dataSource: hrDataSource
        )
        let sdnn30 = FetchLast30DaysSDNNUseCaseImpl(dataSource: dataSource)
        let rmssd30 = FetchLast30DaysRMSSDUseCaseImpl(dataSource: dataSource)
        let rhrUseCase = FetchTodayRHRUseCaseImpl(dataSource: dataSource)
        let rhr60 = FetchLast60DaysRHRUseCaseImpl(dataSource: dataSource)
        let calculateScoreUseCase = CalculateDailyScoreUseCaseImpl()
        let interpretScoreUseCase = InterpretDailyScoreUseCaseImpl()
        let interpretHRVUseCase = InterpretHRVUseCaseImpl()
        _hrvViewModel = StateObject(
            wrappedValue: HRVChartViewModel(
                fetchSDNNUseCase: sdnnUseCase,
                fetchRMSSDUseCase: rmssdUseCase,
                fetch30DaySDNNUseCase: sdnn30,
                fetch30DayRMSSDUseCase: rmssd30,
                fetchRHRUseCase: rhrUseCase,
                fetch60DayRHRUseCase: rhr60,
                fetchHeartRateUseCase: fetchHRUseCase,
                calculateScoreUseCase: calculateScoreUseCase,
                interpretScoreUseCase: interpretScoreUseCase,
                interpretHRVUseCase: interpretHRVUseCase
            )
        )
    }
    var body: some View {
        let endDate = Calendar.current.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: viewModel.selectedDate
        ) ?? viewModel.selectedDate

        let startDate = Calendar.current.date(
            byAdding: .hour,
            value: -24,
            to: endDate
        )!
        
        let interpretation_message = hrvViewModel.detailedExplanation
        let interpretation_label = hrvViewModel.interpretation?.label ?? ""
        
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderView()
                    WellbeingCardView(
                        score: hrvViewModel.dailyScore,
                        status: interpretation_label,
                        description: interpretation_message,
                        onInfoTap: {
                            print(hrvViewModel.dailyScore)
                            showWellbeingInfo = true
                        }
                    )

                    StatsRowView(
                        dailyAverage: 46,
                        baseline: 35
                    )
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .task(id: viewModel.selectedDate) {
                do {
                    try await HealthKitPermissionManager().requestSleepPermission()

                    await hrvViewModel.load(
                        startDate: startDate,
                        endDate: endDate
                    )
                    await stressViewModel.load(for: viewModel.selectedDate)
                } catch {
                    print("❌ HealthKit authorization failed:", error)
                }
            }
            if showWellbeingInfo {
                WellbeingInfoPopup(isPresented: $showWellbeingInfo)
                    .zIndex(10)
            }
        }
        .background(Color(.systemGroupedBackground))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



//#Preview {
//    HomeView()
//}
