//
//  SleepView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//
import SwiftUI
import HealthKit

struct HomeView: View {
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
        
        let sdnn30 = FetchLast30DaysSDNNUseCaseImpl(dataSource: dataSource)
        let rmssd30 = FetchLast30DaysRMSSDUseCaseImpl(dataSource: dataSource)
        let rhrUseCase = FetchTodayRHRUseCaseImpl(dataSource: dataSource)
        let rhr60 = FetchLast60DaysRHRUseCaseImpl(dataSource: dataSource)




        _hrvViewModel = StateObject(
            wrappedValue: HRVChartViewModel(
                fetchSDNNUseCase: sdnnUseCase,
                fetchRMSSDUseCase: rmssdUseCase,
                fetch30DaySDNNUseCase: sdnn30,
                fetch30DayRMSSDUseCase: rmssd30,
                fetchRHRUseCase: rhrUseCase,
                fetch60DayRHRUseCase: rhr60


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

        VStack(spacing: 0) {
            ScrollView {

                Text("Hi, Here is your daily score")
                Text("Pay Attention")
                Text("**score indicator**")
                Divider()

                HStack {
                    Spacer()

                    VStack {
                        Text("Avg HRV Today")

                        let avgRMSSD = average(of: hrvViewModel.rmssdPoints)
                        let avgSDNN = average(of: hrvViewModel.sdnnPoints)
                        
                        let baselineAvgRMSSD = baselineAverage(from: hrvViewModel.baselineRMSSD)
                        let baselineAvgSDNN = baselineAverage(from: hrvViewModel.baselineSDNN)

                        Text("rmssd : \(Int(avgRMSSD))ms")
                        Text("blrmssd : \(Int(baselineAvgRMSSD))ms")
                        Text("sdnn : \(Int(avgSDNN))ms")
                        Text("blsdnn : \(Int(baselineAvgSDNN))ms")
                    }

                    Spacer()

                    VStack {
                        let rhr = hrvViewModel.todayRHR
                        let rhrBaseline = averageRHR(hrvViewModel.baselineRHR)


                        Text("RHR Today")
                        Text("\(rhr)bpm")
                        Text("RHR Baseline")
                        Text("\(rhrBaseline)bpm")

                        Spacer()
                    }

                    Spacer()
                }

                Divider()
                Text("Text description")
                Divider()

                Text("Todays AVG HRV")
                Text("**Chart**")

                HRVChartView(
                    rmssdPoints: hrvViewModel.rmssdPoints,
                    sdnnPoints: hrvViewModel.sdnnPoints,
                    sleepSessions: viewModel.sleepSession.map { [$0] } ?? [],
                    startDate: startDate,
                    endDate: endDate
                )
                .frame(height: 180)

                
                Divider()

                Text("Debug Info")
                Text("RMSSD count: \(hrvViewModel.rmssdPoints.count)")
                Text("SDNN count: \(hrvViewModel.sdnnPoints.count)")

                Divider()
                Text("Todays RHR: 61bpm")
                Text("**Chart**")
                Divider()
                Text("Summary")
                Divider()
            }
//            .task {
//                await hrvViewModel.load()
//                await stressViewModel.load(for: viewModel.selectedDate)
//            }
            .task {
                HealthKitManager.shared.requestAuthorization { success in
                    if success {
                        Task {
                            await hrvViewModel.load()
                            await stressViewModel.load(for: viewModel.selectedDate)
                        }
                    } else {
                        print("HealthKit authorization failed")
                    }
                }
            }

            
        }
    }

    private func dailyAverage(of points: [HRVPoint]) -> Double {
        guard !points.isEmpty else { return 0 }
        return points.map { $0.value }.reduce(0, +) / Double(points.count)
    }
    private func baselineAverage(from historical: [HRVPoint]) -> Double {
        guard !historical.isEmpty else { return 0 }
        return historical.map { $0.value }.reduce(0, +) / Double(historical.count)
    }
    
    private func average(of points: [HRVPoint]) -> Double {
        guard !points.isEmpty else { return 0 }
        return points.map { $0.value }.reduce(0, +) / Double(points.count)
    }
    private func averageRHR(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }
}



//#Preview {
//    let sleepViewModel = SleepViewModel(
//        fetchSleepUseCase: fetchSleepUseCase,
//        fetchSleepStagesUseCase: fetchSleepStagesUseCase,
//        fetchSleepHistoryUseCase: fetchSleepHistoryUseCase,
//        fetchSleepAveragesUseCase: fetchSleepAveragesUseCase
//    )
//
//    HomeView(viewModel: sleepViewModel)
//}
                
//                SleepScoreContainerView(
//                    viewModel: sleepScoreVM,
//                    date: viewModel.selectedDate
//                )
//                
//                Divider()
//                
//                
//                VStack(spacing: 16) {
//                    VStack(spacing: 8) {
//                        Text("Sleep Duration")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        
//                        Text(viewModel.durationText)
//                            .font(.largeTitle.bold())
//                        
//                        Text(viewModel.timeRangeText)
//                            .foregroundColor(.secondary)
//                    }
//                    
//                    Divider()
//                    
//                    VStack(spacing: 12) {
//                        Text("Sleep Details")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        
//                        ForEach(viewModel.sleepStages, id: \.type) { stage in
//                            HStack {
//                                Text(stageLabel(stage.type))
//                                    .font(.subheadline)
//                                
//                                Spacer()
//                                
//                                Text(formatDuration(stage.duration))
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                    
//                    Divider()
//                    VStack(alignment: .leading, spacing: 12) {
//                        
//                        Text("Stress (Last 24 Hours)")
//                            .font(.headline)
//                        
////                        StressChartView(
////                            timeline: stressViewModel.modeledStressTimeline,
////                            rhrTimeline: stressViewModel.rhrStressTimeline,
////                            sleepSessions: viewModel.sleepSession.map { [$0] } ?? [],
////                            startDate: startDate,
////                            endDate: endDate
////                        )
//                        StressChartView(
//                            timeline: stressViewModel.modeledStressTimeline,
//                            rhrTimeline: stressViewModel.rhrStressTimeline,
//                            sleepSessions: viewModel.sleepSession.map { [$0] } ?? [],
//                            startDate: startDate,
//                            endDate: endDate,
//                            peakStress: stressViewModel.peakStress,
//                            peakStressDates: stressViewModel.peakStressDates
//                        )
//                        
//                    }
//                    
//                    Divider()
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Historical Data")
//                            .font(.headline)
//                        
//                        historyRangeSelector
//                        
//                        if viewModel.sleepHistory.isEmpty {
//                            Text("No historical sleep data")
//                                .foregroundColor(.secondary)
//                        } else {
//                            SleepHistoryTimelineChart(
//                                data: viewModel.sleepHistory,
//                                style: viewModel.selectedHistoryRange.timelineStyle
//                            )
//                        }
//                        if let averages = viewModel.sleepAverages {
//                            LazyVGrid(
//                                columns: [
//                                    GridItem(.flexible()),
//                                    GridItem(.flexible())
//                                ],
//                                spacing: 12
//                            ) {
//                                SleepAverageCard(
//                                    title: "Avg Sleep",
//                                    value: formatSleep(averages.averageSleepDuration)
//                                )
//                                
//                                SleepAverageCard(
//                                    title: "Avg HR",
//                                    value: formatOptional(averages.averageHeartRate, suffix: " bpm")
//                                )
//                                
//                                SleepAverageCard(
//                                    title: "Avg HRV",
//                                    value: formatOptional(averages.averageHRV, suffix: " ms")
//                                )
//                                
//                                SleepAverageCard(
//                                    title: "Avg Breath",
//                                    value: formatOptional(
//                                        averages.averageRespiratoryRate,
//                                        suffix: " /min",
//                                        decimals: 1
//                                    )
//                                )
//                            }
//                        }
//                    }
//                    Divider()
//                    VStack(alignment: .leading, spacing: 12) {
//                        
//                        Text("Stress (Last 24 Hours)")
//                            .font(.headline)
//                        
//                        StressChartView(
//                            timeline: stressViewModel.modeledStressTimeline,
//                            rhrTimeline: stressViewModel.rhrStressTimeline,
//                            sleepSessions: viewModel.sleepSession.map { [$0] } ?? [],
//                            startDate: startDate,
//                            endDate: endDate,
//                            peakStress: stressViewModel.peakStress,
//                            peakStressDates: stressViewModel.peakStressDates
//
//                        )
//                        
//                    }
//                    
////                    ModeledStressChartView(
////                        states: stressViewModel.modeledStressTimeline,
////                        sleepSessions: viewModel.sleepSession.map { [$0] } ?? [],
////                        startDate: startDate,
////                        endDate: endDate
////                    )
//                    
//                }
//            }
//        }
//        .task(id: viewModel.selectedDate) {
//
//            await viewModel.onAppear()
//
//            await stressViewModel.load(for: viewModel.selectedDate)
//            print("✅ load(for:) finished — calling loadModeledStress")
//
//
//            await stressViewModel.loadModeledStress(
//                startDate: startDate,
//                endDate: endDate,
//                sleepSessions: viewModel.sleepSession.map { [$0] } ?? []
//            )
//        }
//    }
//    
//    private func formatDuration(_ duration: TimeInterval) -> String {
//        let hours = Int(duration) / 3600
//        let minutes = (Int(duration) % 3600) / 60
//        if hours > 0 {
//            return "\(hours)h \(minutes)m"
//        } else {
//            return "\(minutes)m"
//        }
//    }
//    private func stageLabel(_ type: SleepStageType) -> String {
//        switch type {
//        case .awake:
//            return "Awake"
//        case .rem:
//            return "REM"
//        case .core:
//            return "Core"
//        case .deep:
//            return "Deep"
//        }
//    }
//    private var historyRangeSelector: some View {
//        HStack(spacing: 12) {
//            rangeButton(.week, title: "1W")
//            rangeButton(.twoWeeks, title: "2W")
//            rangeButton(.month, title: "1M")
//            rangeButton(.threeMonths, title: "3M")
//        }
//    }
//    private func rangeButton(
//        _ range: SleepHistoryRange,
//        title: String
//    ) -> some View {
//        Button {
//            Task {
//                await viewModel.selectHistoryRange(range)
//            }
//        } label: {
//            Text(title)
//                .font(.caption.bold())
//                .foregroundColor(
//                    viewModel.selectedHistoryRange == range
//                    ? .white
//                    : .secondary
//                )
//                .padding(.vertical, 6)
//                .padding(.horizontal, 10)
//                .background(
//                    viewModel.selectedHistoryRange == range
//                    ? Color.purple
//                    : Color.clear
//                )
//                .clipShape(Capsule())
//        }
//    }
//    private func formatSleep(_ duration: TimeInterval) -> String {
//        let hours = Int(duration) / 3600
//        let minutes = (Int(duration) % 3600) / 60
//        return "\(hours)h \(minutes)m"
//    }
//    
//    private func formatOptional(
//        _ value: Double?,
//        suffix: String,
//        decimals: Int = 0
//    ) -> String {
//        guard let value else { return "--" }
//        return String(format: "%.\(decimals)f%@", value, suffix)
//    }
//    
//    private func formattedDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEE, dd MMM"
//        return formatter.string(from: date)
//    }
//    
//    
//}
