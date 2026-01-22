//
//  HRChartView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 18/01/26.
//


import SwiftUI
import Charts

struct HRChartView: View {

    /// RAW heart rate samples (bpm)
    let hrSamples: [HeartRateSample]

    let sleepSessions: [SleepSession]
    let startDate: Date
    let endDate: Date

    var body: some View {

        if hrSamples.isEmpty {
            Text("No heart rate data today")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(height: 180)
        } else {

            Chart {

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
                
                // MARK: - Sleep overlay (clamped to chart range)
                ForEach(sleepSessions.indices, id: \.self) { index in
                    let session = sleepSessions[index]

                    let clampedStart = max(session.startDate, startDate)
                    let clampedEnd = min(session.endDate, endDate)

                    if clampedStart < clampedEnd {
                        RectangleMark(
                            xStart: .value("Sleep start", clampedStart),
                            xEnd: .value("Sleep end", clampedEnd),
                            yStart: .value("Bottom", hrRange.lowerBound),
                            yEnd: .value("Top", hrRange.upperBound)
                        )
                        .foregroundStyle(.gray)
                        .opacity(0.12)
                    }
                }

                
                // MARK: - Sleep overlay
                ForEach(sleepSessions.indices, id: \.self) { index in
                    let session = sleepSessions[index]

                    RectangleMark(
                        xStart: .value("Sleep start", session.startDate),
                        xEnd: .value("Sleep end", session.endDate),
                        yStart: .value("Bottom", hrRange.lowerBound),
                        yEnd: .value("Top", hrRange.upperBound)
                    )
                    .foregroundStyle(by: .value("Series", "Sleep"))
                    .opacity(0.15)
                }

                // MARK: - Raw HR (bpm)
                ForEach(hrSamples) { sample in
                    LineMark(
                        x: .value("Time", sample.date),
                        y: .value("HR", sample.bpm)
                    )
                    .foregroundStyle(by: .value("Series", "Heart Rate"))
                    .lineStyle(.init(lineWidth: 1.5))
                    .interpolationMethod(.linear)
                }
            }
            .chartXScale(domain: startDate ... endDate)
            .chartYScale(domain: hrRange)
            .frame(height: 180)
            
            
        }
    }

    // MARK: - Helpers

    private var hrRange: ClosedRange<Double> {
        let values = hrSamples.map(\.bpm)
        let minValue = max((values.min() ?? 40) - 5, 35)
        let maxValue = min((values.max() ?? 120) + 5, 180)
        return minValue ... maxValue
    }
}
