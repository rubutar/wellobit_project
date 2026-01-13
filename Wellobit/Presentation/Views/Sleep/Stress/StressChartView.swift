////
////  StressChartView.swift
////  Wellobit
////
////  Created by Rudi Butarbutar on 11/01/26.
////
//
//import SwiftUI
//import Charts
//
//struct StressChartView: View {
//
//    let timeline: [StressState]
//    let rhrTimeline: [RHRStressPoint]
//    let sleepSessions: [SleepSession]
//    let startDate: Date
//    let endDate: Date
//
//    var body: some View {
//        if timeline.isEmpty {
//            Text("No stress data in the last 24 hours")
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .frame(height: 180)
//        } else {
//            Chart {
//
//                // Sleep overlay
//                ForEach(sleepSessions.indices, id: \.self) { index in
//                    let session = sleepSessions[index]
//
//                    RectangleMark(
//                        xStart: .value("Sleep start", session.startDate),
//                        xEnd: .value("Sleep end", session.endDate),
//                        yStart: .value("Bottom", 0),
//                        yEnd: .value("Top", 100)
//                    )
//                    .foregroundStyle(by: .value("Series", "Sleep"))
//                    .opacity(0.15)
//                }
//
//                // RHR stress (always Double, no gaps)
//                ForEach(rhrTimeline) { point in
//                    LineMark(
//                        x: .value("Time", point.date),
//                        y: .value("Value", point.value)
//                    )
//                    .foregroundStyle(by: .value("Series", "HR"))
//                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [2, 6]))
//                }
//
//                // Stress score (OPTIONAL → USE NaN FOR GAPS)
//                ForEach(timeline) { point in
//                    LineMark(
//                        x: .value("Time", point.date),
//                        y: .value("Value", point.value ?? Double.nan)
//                    )
//                    .foregroundStyle(by: .value("Series", "Stress Score"))
//                    .lineStyle(.init(lineWidth: 2.5))
//                }
//            }
//            .chartXScale(domain: startDate ... endDate)
//            .chartYScale(domain: 0...100)
//            .frame(height: 180)
//        }
//    }
//}


//
//  StressChartView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//

import SwiftUI
import Charts

struct StressChartView: View {

    let timeline: [StressState]
    let rhrTimeline: [RHRStressPoint]
    let sleepSessions: [SleepSession]
    let startDate: Date
    let endDate: Date
    
    let peakStress: Double?
    let peakStressDates: [Date]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            if timeline.isEmpty {
                Text("No stress data in the last 24 hours")
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
                        .foregroundStyle(by: .value("Series", "Sleep"))
                        .opacity(0.15)
                    }

                    // RHR stress
                    ForEach(rhrTimeline) { point in
                        LineMark(
                            x: .value("Time", point.date),
                            y: .value("Value", point.value)
                        )
                        .foregroundStyle(by: .value("Series", "HR"))
                        .lineStyle(
                            StrokeStyle(lineWidth: 1, dash: [2, 6])
                        )
                    }

                    // Stress score (NaN breaks line)
                    ForEach(timeline) { point in
                        LineMark(
                            x: .value("Time", point.date),
                            y: .value("Value", point.value ?? Double.nan)
                        )
                        .foregroundStyle(by: .value("Series", "Stress Score"))
                        .lineStyle(.init(lineWidth: 2.5))
                    }
                    
                    // Peak stress dots
                    ForEach(peakStressDates, id: \.self) { date in
                        if let state = timeline.first(where: { $0.date == date }),
                           let value = state.value {

                            PointMark(
                                x: .value("Time", date),
                                y: .value("Peak", value)   // ✅ RAW stress value
                            )
                            .symbol(.circle)
                            .symbolSize(80)
                            .foregroundStyle(.red)
                        }
                    }

                }
                .chartXScale(domain: startDate ... endDate)
                .chartYScale(domain: 0...100)
                .frame(height: 180)
            }

            // MARK: - Peak Stress Text (NEW)
            if let peakStress {
                Text("Peak stress: \(Int(peakStress.rounded()))%")
                    .font(.caption)
                    .foregroundColor(color(for: peakStress))
            } else {
                Text("Peak stress: --")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Helpers

    private func color(for value: Double) -> Color {
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
