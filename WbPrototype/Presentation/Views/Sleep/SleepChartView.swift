//
//  SleepChartView.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 28/01/26.
//

import SwiftUI
import Charts


struct SleepChartView: View {
    let timeline: [StressState]
    let hrSamples: [HeartRateSample]
    let sleepSessions: [SleepSession]
    let startDate: Date
    let endDate: Date
    
    let peakStress: Double?
    let peakStressDates: [Date]


    private var hrRange: ClosedRange<Double> {
        let values = hrSamples.map(\.bpm)
        let min = values.min() ?? 40
        let max = values.max() ?? 120
        return (min - 5)...(max + 5)
    }

    var body: some View {
        Chart {
            
            // Sleep background
            //            ForEach(sleepSessions.indices, id: \.self) { index in
            //                let session = sleepSessions[index]
            //                RectangleMark(
            //                    xStart: .value("Sleep Start", session.startDate),
            //                    xEnd: .value("Sleep End", session.endDate),
            //                    yStart: .value("Min HR", hrRange.lowerBound),
            //                    yEnd: .value("Max HR", hrRange.upperBound)
            //                )
            //                .foregroundStyle(Color.blue.opacity(0.25))
            //            }
            
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
            
            // Heart Rate line
            ForEach(hrSamples) { sample in
                LineMark(
                    x: .value("Time", sample.date),
                    y: .value("HR", sample.bpm)
                )
                .foregroundStyle(by: .value("Series", "HR"))
                .lineStyle(.init(lineWidth: 1.5))
                .interpolationMethod(.linear)
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
        .chartYScale(domain: 0...hrRange.upperBound)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 2)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(
                            date,
                            format: .dateTime.hour(.twoDigits(amPM: .omitted))
                        )
                    }
                }
            }
        }
        // MARK: - Peak Stress Text (NEW)
        .chartOverlay { _ in
            VStack {
                HStack {
                    if let peakStress {
                        Text("Peak stress: \(Int(peakStress.rounded()))%")
                            .font(.caption)
                            .foregroundColor(Color.black)
                    } else {
                        Text("Peak stress: --")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)
                
                Spacer()
            }
        }
    }

    // MARK: - Helpers

    private func color(for value: Double) -> Color {
        switch value {
        case 0..<25:
            return .green.opacity(0.85)
        case 25..<50:
            return .yellow.opacity(0.85)
        case 50..<75:
            return .orange.opacity(0.85)
        default:
            return .red.opacity(0.85)
        }
    }

}
