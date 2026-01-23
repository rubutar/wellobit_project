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
    
    init(
        viewModel: SleepViewModel,
        hrvViewModel: HRVChartViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _hrvViewModel = StateObject(wrappedValue: hrvViewModel)
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
        
        let interpretation_message = hrvViewModel.currentDetailedExplanation
        let interpretation_label = hrvViewModel.currentInterpretation?.label ?? ""
        
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    HeaderView()
                    WellbeingCardView(
                        score: hrvViewModel.currentScore,
                        status: interpretation_label,
                        description: interpretation_message,
                        onInfoTap: {
                            print(hrvViewModel.dailyScore)
                            showWellbeingInfo = true
                        },
                        hrvViewModel: hrvViewModel,
                        startDate: startDate,
                        endDate: endDate,
                        sleepSessions: viewModel.sleepSession.map { [$0] } ?? []              
                    )
                    HStack(spacing: 16) {
                        AvgHRVCardView(
                            title: "Current HRV",
                            value: Int(hrvViewModel.currentSDNN),
                            unit: "ms",
                            recentAverage: Int(hrvViewModel.baselineSDNNValue),
                            isUp: Int(hrvViewModel.currentSDNN) > Int(hrvViewModel.baselineSDNNValue)
                        )


                        AvgHRVCardView(
                            title: "RHR Today",
                            value: Int(hrvViewModel.currentRHRValue),
                            unit: "bpm",
                            recentAverage: Int(hrvViewModel.baselineAvgRHR),
                            isUp: Int(hrvViewModel.currentRHRValue) > Int(hrvViewModel.baselineAvgRHR)
                        )

                    }



                    
//                    StatsRowView(
//                        dailyAverage: 0,
//                        baseline: 0
//                    )
                    
//                    ---------------------------------

                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Debug, will remove later")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            VStack (alignment: .leading) {
                                Text("Current Score")
                                    .font(.body)
                                Text("\(hrvViewModel.currentScore)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("\(hrvViewModel.interpretation?.state)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("\(hrvViewModel.interpretation?.context)")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }

                            Divider()
                            
                            VStack (alignment: .leading) {
                                Text("HRV - RMSSD")
                                    .font(.body)
                                Text("\(Int(hrvViewModel.currentRMSSD))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Baseline - RMSSD")
                                    .font(.body)
                                Text("\(Int(hrvViewModel.baselineRMSSDValue))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("HRV - SDNN")
                                    .font(.body)
                                Text("\(Int(hrvViewModel.currentSDNN))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Baseline - SDNN")
                                    .font(.body)
                                Text("\(Int(hrvViewModel.baselineSDNNValue))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("RHR")
                                    .font(.body)
                                Text("\(Int(hrvViewModel.currentRHRValue))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Baseline - RHR")
                                    .font(.body)
                                Text("\(viewModel.sleepSession.map { [$0] } ?? [])")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            
                            
                        }
                        
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10)
                    
                    
//                    ---------------------------------
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
                    print("HealthKit authorization failed:", error)
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


#Preview {
    HomeView(
        viewModel: SleepViewModel.mock(),
        hrvViewModel: HRVChartViewModel.mock()
    )
}

