//
//  ModeledStressChartView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 12/01/26.
//

import SwiftUI
import Charts

struct ModeledStressChartView: View {

    let states: [StressState]
    let sleepSessions: [SleepSession]
    let startDate: Date
    let endDate: Date

    var body: some View {

        if states.isEmpty {
            Text("No modeled stress data")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(height: 180)
        } else {
            Chart {

                // Sleep overlay
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

                // Modeled stress line (AUTOMATIC GAPS ON NIL)
                ForEach(states) { state in
                    LineMark(
                        x: .value("Time", state.date),
                        y: .value("Stress", state.value ?? Double.nan)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(color(for: state.value))
                    .lineStyle(.init(lineWidth: 2.5))
                }
            }
            .chartXScale(domain: startDate ... endDate)
            .chartYScale(domain: 0...100)
            .frame(height: 180)
        }
    }

    // MARK: - Helpers

    private func color(for value: Double?) -> Color {
        guard let value else {
            return .clear   // gaps / no data
        }

        switch value {
        case 0..<25:
            return .green
        case 25..<50:
            return .yellow
        case 50..<75:
            return .orange
        default:
            return .red
        }
    }
}
