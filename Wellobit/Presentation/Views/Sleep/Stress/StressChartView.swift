//
//  StressChartView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import SwiftUI
import Charts

struct StressChartView: View {
    
    let timeline: [StressTimelinePoint]
    let sleepSessions: [SleepSession]
    let startDate: Date
    let endDate: Date

    
    var body: some View {
        if timeline.isEmpty {
            Text("No stress data in the last 24 hours")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(height: 180)
        } else {
            Chart {

                ForEach(sleepSessions.indices, id: \.self) { index in
                    let session = sleepSessions[index]

                    RectangleMark(
                        xStart: .value("Sleep start", session.startDate),
                        xEnd: .value("Sleep end", session.endDate),
                        yStart: .value("Bottom", 0),
                        yEnd: .value("Top", 100)
                    )
                    .foregroundStyle(.blue.opacity(0.15))
                }

                ForEach(timeline) { point in
                    LineMark(
                        x: .value("Time", point.date),
                        y: .value("Stress", point.stressScore)
                    )
                    .foregroundStyle(color(for: point.stressLevel))
                    .lineStyle(.init(lineWidth: 2))
                }
            }
            .chartXScale(domain: startDate ... endDate)
            .chartYScale(domain: 0...100)
            .frame(height: 180)
        }
    }
}


private func color(for level: StressLevel) -> Color {
    switch level {
    case .low:
        return .green
    case .medium:
        return .yellow
    case .high:
        return .orange
    case .veryHigh:
        return .red
    }
}
