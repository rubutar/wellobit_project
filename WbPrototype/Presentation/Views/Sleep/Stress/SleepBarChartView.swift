//
//  SleepBarChartView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import SwiftUI
import Charts

struct SleepBarChartView: View {

    let sessions: [SleepSession]

    var body: some View {
        Chart {
            ForEach(sessions.indices, id: \.self) { index in
                let session = sessions[index]

                RectangleMark(
                    xStart: .value("Sleep start", session.startDate),
                    xEnd: .value("Sleep end", session.endDate),
                    yStart: .value("Bottom", 0),
                    yEnd: .value("Top", 1)
                )
                .foregroundStyle(.blue.opacity(0.3))
            }
        }
        .chartYScale(domain: 0...1)
        .frame(height: 100)
    }
}
