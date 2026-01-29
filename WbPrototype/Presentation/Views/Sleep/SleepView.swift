//
//  SleepView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//
import SwiftUI
import HealthKit

struct SleepView: View {
    @StateObject var viewModel: SleepViewModel
    @StateObject private var sleepScoreVM: SleepScoreViewModel
    @StateObject private var stressViewModel = StressViewModel()
    @StateObject private var hrvViewModel: HRVChartViewModel
    
    init(
        viewModel: SleepViewModel,
        sleepScoreVM: SleepScoreViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _sleepScoreVM = StateObject(wrappedValue: sleepScoreVM)
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
                interpretScoreUseCase: interpretScoreUseCase,
                interpretHRVUseCase: interpretHRVUseCase,
                fetchLatestSnapshotUseCase: fetchLatestSnapshotUseCase,
                fetchHRBaselineUseCase: fetchHRBaselineUseCase

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
        
        ZStack {
            Color.tmRed
                .opacity(0.15)
                .ignoresSafeArea()
            VStack (spacing: 0) {
                HStack(spacing: 12) {
                        Button {
                            Task { viewModel.goToPreviousDay() }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                        }
                    
                    Text(formattedDate(viewModel.selectedDate))
                        .font(.headline)
                        .frame(minWidth: 120)
                    
                        Button {
                            Task { viewModel.goToNextDay() }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.headline)
                    }
                }
            
                .padding(.vertical, 8)
                
                Divider()
                
                ScrollView{
                    card {
                        SleepScoreContainerView(
                            viewModel: sleepScoreVM,
                            date: viewModel.selectedDate
                        )
                        .padding(.top)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        card {
                            VStack {
                                Text("Sleep Duration")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(viewModel.durationText)
                                    .font(.largeTitle.bold())
                                Text(viewModel.timeRangeText)
                                    .foregroundColor(.secondary)
                            }
                        }
                        card {
                            VStack {
                                Text("Sleep Details")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                ForEach(viewModel.sleepStages, id: \.type) { stage in
                                    HStack {
                                        Text(stageLabel(stage.type))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Text(formatDuration(stage.duration))
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
//                    card {
//                        StressChartView(
//                            timeline: stressViewModel.modeledStressTimeline,
//                            hrTimeline: stressViewModel.hrStressTimeline,
//                            sleepSessions: viewModel.sleepSession.map { [$0] } ?? [],
//                            startDate: startDate,
//                            endDate: endDate,
//                            peakStress: stressViewModel.peakStress,
//                            peakStressDates: stressViewModel.peakStressDates
//                        )
//                    }
                    .padding(.horizontal)
                    
                    card {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Historical Data")
                                .font(.headline)
                            
                            historyRangeSelector
                            
                            if viewModel.sleepHistory.isEmpty {
                                Text("No historical sleep data")
                                    .foregroundColor(.secondary)
                            } else {
                                SleepHistoryTimelineChart(
                                    data: viewModel.sleepHistory,
                                    style: viewModel.selectedHistoryRange.timelineStyle
                                )
                            }
                            if let averages = viewModel.sleepAverages {
                                LazyVGrid(
                                    columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ],
                                    spacing: 12
                                ) {
                                    SleepAverageCard(
                                        title: "Avg Sleep",
                                        value: formatSleep(averages.averageSleepDuration)
                                    )
                                    
                                    SleepAverageCard(
                                        title: "Avg HR",
                                        value: formatOptional(averages.averageHeartRate, suffix: " bpm")
                                    )
                                    
                                    SleepAverageCard(
                                        title: "Avg HRV",
                                        value: formatOptional(averages.averageHRV, suffix: " ms")
                                    )
                                    
                                    SleepAverageCard(
                                        title: "Avg Breath",
                                        value: formatOptional(
                                            averages.averageRespiratoryRate,
                                            suffix: " /min",
                                            decimals: 1
                                        )
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    card {
                        SleepChartView(
                            timeline: stressViewModel.modeledStressTimeline,
                            hrSamples: hrvViewModel.heartRateSamples,
                            sleepSessions: viewModel.sleepSession.map { [$0] } ?? [],
                            startDate: startDate,
                            endDate: endDate,
                            peakStress: stressViewModel.peakStress,
                            peakStressDates: stressViewModel.peakStressDates

                        )
                        .frame(height: 200)
                        
//                        StressChartView(
//                            timeline: stressViewModel.modeledStressTimeline,
//                            hrTimeline: stressViewModel.hrStressTimeline,
//                            sleepSessions: viewModel.sleepSession.map { [$0] } ?? [],
//                            startDate: startDate,
//                            endDate: endDate,
//                            peakStress: stressViewModel.peakStress,
//                            peakStressDates: stressViewModel.peakStressDates
//                        )
                    }
                    .padding(.horizontal)
                    
                    
                    let averages = viewModel.sleepAverages
                    let summary = DailyStressSummaryBuilder.build(
                        peakStress: stressViewModel.peakStress,
                        sleepScore: sleepScoreVM.sleepScore?.value
                    )

                    card {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(summary.title)
                                .font(.headline)
                                .foregroundColor(summary.accentColor)
                            
                            Text(summary.body)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
            }
//            .task(id: viewModel.selectedDate) {
//                await viewModel.onAppear()
//                await stressViewModel.load(for: viewModel.selectedDate)
//                print("✅ load(for:) finished — calling loadModeledStress")
//                await stressViewModel.loadModeledStress(
//                    startDate: startDate,
//                    endDate: endDate,
//                    sleepSessions: viewModel.sleepSession.map { [$0] } ?? []
//                )
//            }
//            .task(id: viewModel.selectedDate) {
//                await viewModel.onAppear()
//                print("onappear")
//                await stressViewModel.load(for: viewModel.selectedDate)
//                print("load selected date")
//
//            }
//            .task(id: viewModel.sleepSession?.startDate) {
//                guard let session = viewModel.sleepSession else { return }
//
//                await stressViewModel.loadModeledStress(
//                    startDate: startDate,
//                    endDate: endDate,
//                    sleepSessions: [session]
//                )
//                await hrvViewModel.load(
//                    startDate: startDate,
//                    endDate: endDate
//                )
//            }
            .task(id: viewModel.selectedDate) {

                let date = viewModel.selectedDate

                // 1️⃣ Load base data (sleepSession, etc.)
                await viewModel.onAppear()

                guard let session = viewModel.sleepSession else {
                    return
                }

                // 2️⃣ Load stress for date
                await stressViewModel.load(for: date)

                // 3️⃣ Load modeled stress & HRV (depends on sleepSession)
                await stressViewModel.loadModeledStress(
                    startDate: startDate,
                    endDate: endDate,
                    sleepSessions: [session]
                )

                await hrvViewModel.load(
                    startDate: startDate,
                    endDate: endDate
                )
            }

        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    private func stageLabel(_ type: SleepStageType) -> String {
        switch type {
        case .awake:
            return "Awake"
        case .rem:
            return "REM"
        case .core:
            return "Core"
        case .deep:
            return "Deep"
        }
    }
    private var historyRangeSelector: some View {
        HStack(spacing: 12) {
            rangeButton(.week, title: "1W")
            rangeButton(.twoWeeks, title: "2W")
            rangeButton(.month, title: "1M")
            rangeButton(.threeMonths, title: "3M")
        }
    }
    private func rangeButton(
        _ range: SleepHistoryRange,
        title: String
    ) -> some View {
        Button {
            Task {
                await viewModel.selectHistoryRange(range)
            }
        } label: {
            Text(title)
                .font(.caption.bold())
                .foregroundColor(
                    viewModel.selectedHistoryRange == range
                    ? .white
                    : .secondary
                )
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    viewModel.selectedHistoryRange == range
                    ? Color.purple
                    : Color.clear
                )
                .clipShape(Capsule())
        }
    }
    private func formatSleep(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    private func formatOptional(
        _ value: Double?,
        suffix: String,
        decimals: Int = 0
    ) -> String {
        guard let value else { return "--" }
        return String(format: "%.\(decimals)f%@", value, suffix)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM"
        return formatter.string(from: date)
    }
    
    func card<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}




#Preview {
    SleepView(
        viewModel: SleepViewModel.mock(),
        sleepScoreVM: SleepScoreViewModel.mock()

    )
}
