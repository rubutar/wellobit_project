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
    @State private var showInfo = false
    @Environment(\.dataMode) private var dataMode



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
        let calculateCurrentScoreUseCase = CalculateCurrentScoreUseCaseImpl()
        let interpretScoreUseCase = InterpretDailyScoreUseCaseImpl()
        let interpretHRVUseCase = InterpretHRVUseCaseImpl()
        let fetchLatestSnapshotUseCase = FetchLatestHRVSnapshotUseCaseImpl(
            fetchTodayHRVUseCase: sdnnUseCase,
            fetchTodayRMSSDUseCase: rmssdUseCase,
            fetchTodayHeartRateUseCase: fetchHRUseCase
        )
        let fetchHRBaselineUseCase = FetchHRBaselineUseCaseImpl(
            dataSource: hrDataSource
        )
        
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
                calculateCurrentScoreUseCase: calculateCurrentScoreUseCase,
                interpretScoreUseCase: interpretScoreUseCase,
                interpretHRVUseCase: interpretHRVUseCase,
                fetchLatestSnapshotUseCase: fetchLatestSnapshotUseCase,
                fetchHRBaselineUseCase: fetchHRBaselineUseCase
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
        let calendar = Calendar.current

        let startDate = calendar.startOfDay(for: viewModel.selectedDate)

        let endDate = calendar.date(
            byAdding: DateComponents(day: 1, second: -1),
            to: startDate
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
                        sleepSessions: viewModel.sleepSession.map { [$0] } ?? [],
                        interpretation: hrvViewModel.currentInterpretation
                    )
                    HStack(spacing: 16) {
                        AvgHRVCardView(
                            title: "Current HRV",
                            value: Int(hrvViewModel.latestSnapshot?.sdnn?.value ?? 0),
                            unit: "ms",
                            time: hrvViewModel.latestSnapshot?.sdnn?.date.hourMinuteString ?? "--",
                            recentAverage: Int(hrvViewModel.baselineSDNNValue),
                            isUp: Int(hrvViewModel.latestSnapshot?.sdnn?.value ?? 0) > Int(hrvViewModel.baselineSDNNValue)
                        )


                        AvgHRVCardView(
                            title: "Current Heart Rate",
                            value: Int(hrvViewModel.latestSnapshot?.heartRate?.bpm ?? 0),
                            unit: "bpm",
                            time: hrvViewModel.latestSnapshot?.heartRate?.date.hourMinuteString ?? "--",
                            recentAverage: Int(hrvViewModel.hrBaseline7Days ?? 0),
                            isUp: Int(hrvViewModel.latestSnapshot?.heartRate?.bpm ?? 0) > Int(hrvViewModel.hrBaseline7Days ?? 0)
                        )

                    }

                    VStack {
                        Button {
                            showInfo = true
                        } label: {
                            Text("More info")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        
                    }
                    .sheet(isPresented: $showInfo) {
                        MoreHRVInfoSheet(
            //                viewModel: SleepViewModel.mock(),
                            hrvViewModel: hrvViewModel,
                            startDate: startDate,
                            endDate: endDate,
                            sleepSessions: []
                        )
                    }
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
                    await hrvViewModel.loadLatestSnapshot()
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

extension Date {
    var hourMinuteString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

#Preview {
    HomeView(
        viewModel: SleepViewModel.mock(),
        hrvViewModel: HRVChartViewModel.mock()
    )
}

