//
//  PreviewHomeView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 19/01/26.
//


import SwiftUI
import HealthKit

struct PreviewHomeView: View {

    @StateObject var viewModel: SleepViewModel
    @StateObject private var stressViewModel = StressViewModel()
    @StateObject private var hrvViewModel: HRVChartViewModel

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

        VStack(spacing: 0) {
            // MARK: - Date Navigation (Same as SleepView)
//            HStack(spacing: 12) {
//                Button {
//                    Task { await viewModel.goToPreviousDay() }
//                } label: {
//                    Image(systemName: "chevron.left")
//                        .font(.headline)
//                }
//
//                Text(formattedDate(viewModel.selectedDate))
//                    .font(.headline)
//                    .frame(minWidth: 120)
//
//                Button {
//                    Task { await viewModel.goToNextDay() }
//                } label: {
//                    Image(systemName: "chevron.right")
//                        .font(.headline)
//                }
//            }
//            .padding(.vertical, 8)
            
            ScrollView {

//                Text("Hi, Here is your daily score")
                Text(hrvViewModel.scoreMessage)
                    .font(.body)
                if let interpretation = hrvViewModel.interpretation {

                    Divider()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("HRV State: \(interpretation.message)")
                            .font(.caption2)
                        
                        Text("HRV State: \(interpretation.state)")
                            .font(.caption2)

                        Text("HR Context: \(interpretation.context)")
                            .font(.caption2)
                    }
                    
                    
                }
                Text("Daily Score: \(hrvViewModel.dailyScore)")
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

                HRChartView(
                    hrSamples: hrvViewModel.heartRateSamples,
                    sleepSessions: viewModel.sleepSession.map { [$0] } ?? [],
                    startDate: startDate,
                    endDate: endDate
                )


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
//            .task(id: viewModel.selectedDate) {
//
//                await viewModel.onAppear()
//
//                HealthKitManager.shared.requestAuthorization { success in
//                    if success {
//                        Task {
////                            await hrvViewModel.load()
//                            await hrvViewModel.load(
//                                startDate: startDate,
//                                endDate: endDate
//                            )
//                            await stressViewModel.load(for: viewModel.selectedDate)
//                        }
//                    } else {
//                        print("HealthKit authorization failed")
//                    }
//                }
//            }


            
        }
        .presentationDragIndicator(.visible)
        .presentationDetents(
            [.medium, .large],
            selection: .constant(.medium)
        )
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
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM"
        return formatter.string(from: date)
    }

}

#Preview {
    PreviewHomeView(
        viewModel: SleepViewModel.mock(),
        hrvViewModel: HRVChartViewModel.mock()
    )
}

