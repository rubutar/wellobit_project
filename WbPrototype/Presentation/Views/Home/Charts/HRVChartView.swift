import Foundation
import SwiftUI
import Charts

struct HRVChartView: View {

    let rmssdPoints: [HRVPoint]
    let sdnnPoints: [HRVPoint]
    let sleepSessions: [SleepSession]
    let startDate: Date
    let endDate: Date

//    var body: some View {
//
//        let sortedRMSSD = rmssdPoints.sorted { $0.date < $1.date }
//        let sortedSDNN  = sdnnPoints.sorted { $0.date < $1.date }
//
//        let avgRMSSD = dailyAverage(of: rmssdPoints)
//        let avgSDNN  = dailyAverage(of: sdnnPoints)
//
////        if rmssdPoints.isEmpty && sdnnPoints.isEmpty {
////            Text("No HRV data today")
////                .font(.caption)
////                .foregroundColor(.secondary)
////                .frame(height: 180)
////        } else {
//
//            Chart {
//                // MARK: - Invisible baseline (keeps grid alive)
//                RuleMark(y: .value("Baseline", hrvRange.lowerBound))
//                    .foregroundStyle(.clear)
//
//                // MARK: - Sleep overlay (clamped)
//                ForEach(sleepSessions.indices, id: \.self) { index in
//                    let session = sleepSessions[index]
//
//                    let clampedStart = max(session.startDate, startDate)
//                    let clampedEnd   = min(session.endDate, endDate)
//
//                    if clampedStart < clampedEnd {
//                        RectangleMark(
//                            xStart: .value("Sleep start", clampedStart),
//                            xEnd: .value("Sleep end", clampedEnd),
//                            yStart: .value("Bottom", hrvRange.lowerBound),
//                            yEnd: .value("Top", hrvRange.upperBound)
//                        )
//                        .foregroundStyle(.gray)
//                        .opacity(0.12)
//                    }
//                }
//
//                // MARK: - RMSSD
//                ForEach(sortedRMSSD) { point in
//                    LineMark(
//                        x: .value("Time", point.date),
//                        y: .value("RMSSD", point.value)
//                    )
//                    .foregroundStyle(by: .value("Metric", "RMSSD"))
//                    .lineStyle(.init(lineWidth: 1.5))
//
//                    PointMark(
//                        x: .value("Time", point.date),
//                        y: .value("RMSSD", point.value)
//                    )
//                    .foregroundStyle(by: .value("Metric", "RMSSD"))
//                }
//
//                // MARK: - SDNN
//                ForEach(sortedSDNN) { point in
//                    LineMark(
//                        x: .value("Time", point.date),
//                        y: .value("SDNN", point.value)
//                    )
//                    .foregroundStyle(by: .value("Metric", "SDNN"))
//                    .lineStyle(.init(lineWidth: 1.5))
//
//                    PointMark(
//                        x: .value("Time", point.date),
//                        y: .value("SDNN", point.value)
//                    )
//                    .foregroundStyle(by: .value("Metric", "SDNN"))
//                }
//
//                // MARK: - Avg RMSSD
//                if avgRMSSD > 0 {
//                    RuleMark(y: .value("Avg RMSSD", avgRMSSD))
//                        .foregroundStyle(.green)
//                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
//                        .annotation(position: .top) {
//                            Text("Avg RMSSD")
//                                .font(.caption2)
//                                .foregroundColor(.green)
//                        }
//                }
//
//                // MARK: - Avg SDNN
//                if avgSDNN > 0 {
//                    RuleMark(y: .value("Avg SDNN", avgSDNN))
//                        .foregroundStyle(.blue)
//                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
//                        .annotation(position: .bottom) {
//                            Text("Avg SDNN")
//                                .font(.caption2)
//                                .foregroundColor(.blue)
//                        }
//                }
//            }
//            .chartForegroundStyleScale([
//                "RMSSD": .green,
//                "SDNN": .blue
//            ])
////            .chartXScale(domain: startDate ... endDate)
////            .chartYScale(domain: hrvRange)
//            .chartXAxis {
//                AxisMarks(values: .stride(by: .hour, count: 2)) { value in
//                    AxisGridLine()
//                    AxisTick()
//                    AxisValueLabel {
//                        if let date = value.as(Date.self) {
//                            Text(date, format: .dateTime.hour(.twoDigits(amPM: .omitted)))
//                        }
//                    }
//                }
//            }
//            .chartYAxis {
//                AxisMarks(values: .stride(by: 25)) { value in
//                    AxisGridLine()
//                    AxisTick()
//                    AxisValueLabel()
//                }
//            }
//            .frame(height: 180)
//        }
//    }

    var body: some View {
        let avgRMSSD = dailyAverage(of: rmssdPoints)
        let avgSDNN  = dailyAverage(of: sdnnPoints)


//        if hrSamples.isEmpty {
//            Text("No heart rate data today")
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .frame(height: 180)
//        } else {

            Chart {
//                ForEach(sleepSessions.indices, id: \.self) { index in
//                    let session = sleepSessions[index]
//
//                    let clampedStart = max(session.startDate, startDate)
//                    let clampedEnd = min(session.endDate, endDate)
//
//                    if clampedStart < clampedEnd {
//                        RectangleMark(
//                            xStart: .value("Sleep start", clampedStart),
//                            xEnd: .value("Sleep end", clampedEnd),
//                            yStart: .value("Bottom", hrRange.lowerBound),
//                            yEnd: .value("Top", hrRange.upperBound)
//                        )
//                        .foregroundStyle(.gray)
//                        .opacity(0.12)
//                    }
//                }

                
                // MARK: - Sleep overlay
//                ForEach(sleepSessions.indices, id: \.self) { index in
//                    let session = sleepSessions[index]
//
//                    RectangleMark(
//                        xStart: .value("Sleep start", session.startDate),
//                        xEnd: .value("Sleep end", session.endDate),
//                        yStart: .value("Bottom", hrRange.lowerBound),
//                        yEnd: .value("Top", hrRange.upperBound)
//                    )
//                    .foregroundStyle(by: .value("Series", "Sleep"))
//                    .opacity(0.15)
//                }

                // MARK: - Raw HR (bpm)
                ForEach(rmssdPoints) { sample in
                    LineMark(
                        x: .value("Time", sample.date),
                        y: .value("RMSSD", sample.value)
                    )
//                    .foregroundStyle(by: .value("Series", "Heart Rate"))
//                    .lineStyle(.init(lineWidth: 1.5))
//                    .interpolationMethod(.linear)
                    
//                    LineMark(
//                        x: .value("Time", point.date),
//                        y: .value("RMSSD", point.value)
//                    )
                    .foregroundStyle(by: .value("Metric", "RMSSD"))
                    .lineStyle(.init(lineWidth: 1.5))
                    
                    PointMark(
                        x: .value("Time", sample.date),
                        y: .value("RMSSD", sample.value)
                    )
                    .foregroundStyle(by: .value("Metric", "RMSSD"))
                }
                
                ForEach(sdnnPoints) { sample in
                    LineMark(
                        x: .value("Time", sample.date),
                        y: .value("SDNN", sample.value)
                    )
//                    .foregroundStyle(by: .value("Series", "Heart Rate"))
//                    .lineStyle(.init(lineWidth: 1.5))
//                    .interpolationMethod(.linear)
                    
//                    LineMark(
//                        x: .value("Time", point.date),
//                        y: .value("RMSSD", point.value)
//                    )
                    .foregroundStyle(by: .value("Metric", "SDNN"))
                    .lineStyle(.init(lineWidth: 1.5))
                    
                    PointMark(
                        x: .value("Time", sample.date),
                        y: .value("SDNN", sample.value)
                    )
                    .foregroundStyle(by: .value("Metric", "SDNN"))
                }
                

                
                if avgRMSSD > 0 {
                    RuleMark(y: .value("Avg RMSSD", avgRMSSD))
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .annotation(position: .top) {
                            Text("Avg RMSSD")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                }
                
                if avgSDNN > 0 {
                    RuleMark(y: .value("Avg SDNN", avgSDNN))
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .annotation(position: .top) {
                            Text("Avg SDNN")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                }
                
//                if avgRHR > 0 {
//                    RuleMark(
//                        y: .value("Avg RHR", avgRHR)
//                    )
//                    .foregroundStyle(.orange)
//                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
//                    .annotation(position: .bottom) {
//                        Text("Avg RHR")
//                            .font(.caption2)
//                            .foregroundColor(.orange)
//                    }
//                }
            }
            .chartXScale(domain: startDate ... endDate)
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 2)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.hour(.twoDigits(amPM: .omitted)))
                        }
                    }
                }
            }
            .chartYScale(domain: hrvRange)
            .frame(height: 180)
            
            
        }
//    }
    
    // MARK: - Helpers

    private var hrvRange: ClosedRange<Double> {
        let allValues = rmssdPoints.map(\.value) + sdnnPoints.map(\.value)
        let maxValue = max(allValues.max() ?? 100, 100)
        return 0 ... maxValue
    }

    private func dailyAverage(of points: [HRVPoint]) -> Double {
        guard !points.isEmpty else { return 0 }
        return points.map(\.value).reduce(0, +) / Double(points.count)
    }
}
