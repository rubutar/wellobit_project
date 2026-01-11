//
//  SleepOverlayChartView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import SwiftUI
import Charts

struct SleepOverlayChartView: View {

    let sleepSessions: [SleepSession]

    var body: some View {
        Chart {
            ForEach(sleepSessions.indices, id: \.self) { index in
                let session = sleepSessions[index]

                RectangleMark(
                    xStart: .value("Sleep start", session.startDate),
                    xEnd: .value("Sleep end", session.endDate),
                    yStart: .value("Min", 0),
                    yEnd: .value("Max", 1)
                )
                .foregroundStyle(.blue.opacity(0.3))
            }
        }
        .chartYScale(domain: 0...1)
        .frame(height: 120)
    }
}

struct SleepOverlayDebugView: View {

    @StateObject private var viewModel: SleepOverlayViewModel

    init(fetchSleepUseCase: FetchSleepSessionUseCase) {
        _viewModel = StateObject(
            wrappedValue: SleepOverlayViewModel(
                fetchSleepUseCase: fetchSleepUseCase
            )
        )
    }

    var body: some View {
        VStack {
            SleepOverlayChartView(
                sleepSessions: viewModel.sleepSessions
            )
        }
        .task {
            await viewModel.load(for: Date())
        }
    }
}

#Preview {
    let start = Calendar.current.date(
        bySettingHour: 23,
        minute: 0,
        second: 0,
        of: Date()
    )!

    let end = Calendar.current.date(
        bySettingHour: 7,
        minute: 0,
        second: 0,
        of: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    )!

    SleepOverlayChartView(
        sleepSessions: [
            SleepSession(
                startDate: start,
                endDate: end,
                duration: end.timeIntervalSince(start)
            )
        ]
    )
    .padding()
}
