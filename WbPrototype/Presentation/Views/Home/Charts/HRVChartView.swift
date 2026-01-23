import Foundation
import SwiftUI
import Charts

struct HRVChartView: View {

    let rmssdPoints: [HRVPoint]
    let sdnnPoints: [HRVPoint]
    let sleepSessions: [SleepSession]
    let startDate: Date
    let endDate: Date
    

    var body: some View {
        let sortedRMSSD = rmssdPoints.sorted { $0.date < $1.date }
        let sortedSDNN  = sdnnPoints.sorted { $0.date < $1.date }
        let avgRMSSD = dailyAverage(of: rmssdPoints)
        let avgSDNN = dailyAverage(of: sdnnPoints)
        
        
        if rmssdPoints.isEmpty && sdnnPoints.isEmpty {
            Text("No HRV data today")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(height: 180)
        } else {
//            Chart {
//                ForEach(sleepSessions.indices, id: \.self) { index in
//                    let session = sleepSessions[index]
//
//                    RectangleMark(
//                        xStart: .value("Sleep start", session.startDate),
//                        xEnd: .value("Sleep end", session.endDate),
//                        yStart: .value("Bottom", 0),
//                        yEnd: .value("Top", maxHRV)
//                    )
//                    .foregroundStyle(by: .value("Series", "Sleep"))
//                    .opacity(0.15)
//                }
//
//                ForEach(sortedRMSSD) { point in
//                    LineMark(
//                        x: .value("Time", point.date),
//                        y: .value("RMSSD", point.value)
//                    )
//                    .foregroundStyle(.green.opacity(0.25))
////                    .interpolationMethod(.catmullRom)
//
//                    // Foreground dots (legend-aware)
//                    PointMark(
//                        x: .value("Time", point.date),
//                        y: .value("RMSSD", point.value)
//                    )
//                    .foregroundStyle(by: .value("Metric", "RMSSD"))
//                    .symbolSize(22)
//                }
//                
//                ForEach(sortedSDNN) { point in
//                    LineMark(
//                        x: .value("Time", point.date),
//                        y: .value("SDNN", point.value)
//                    )
//                    .foregroundStyle(.blue.opacity(0.25))
////                    .interpolationMethod(.catmullRom)
//
//                    // Foreground dots (legend-aware)
//                    PointMark(
//                        x: .value("Time", point.date),
//                        y: .value("SDNN", point.value)
//                    )
//                    .foregroundStyle(by: .value("Metric", "SDNN"))
//                    .symbolSize(22)
//                }
//                
//                // Avg RMSSD line
//                if avgRMSSD > 0 {
//                    RuleMark(
//                        y: .value("Avg RMSSD", avgRMSSD)
//                    )
//                    .foregroundStyle(.green)
//                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
//                    .annotation(position: .top) {
//                        Text("Avg RMSSD")
//                            .font(.caption2)
//                            .foregroundColor(.green)
//                    }
//                }
//
//                // Avg SDNN line
//                if avgSDNN > 0 {
//                    RuleMark(
//                        y: .value("Avg SDNN", avgSDNN)
//                    )
//                    .foregroundStyle(.orange)
//                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
//                    .annotation(position: .bottom) {
//                        Text("Avg SDNN")
//                            .font(.caption2)
//                            .foregroundColor(.orange)
//                    }
//                }
//                
//            }
//            .chartXScale(domain: startDate ... endDate)
//            .chartYScale(domain: 0...maxHRV)
//            .chartLegend(position: .bottom)
//            .frame(height: 180)
            
            
            let sortedRMSSD = rmssdPoints.sorted { $0.date < $1.date }
            let sortedSDNN  = sdnnPoints.sorted { $0.date < $1.date }

            Chart {
                
                ForEach(sleepSessions.indices, id: \.self) { index in
                    let session = sleepSessions[index]
                    
                    RectangleMark(
                        xStart: .value("Sleep start", session.startDate),
                        xEnd: .value("Sleep end", session.endDate),
                        yStart: .value("Bottom", 0),
                        yEnd: .value("Top", maxHRV)
                    )
                    .foregroundStyle(by: .value("Series", "Sleep"))
                    .opacity(0.15)
                }
                
                ForEach(sortedRMSSD) { point in
                    LineMark(
                        x: .value("Time", point.date),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(by: .value("Metric", "RMSSD"))

                    PointMark(
                        x: .value("Time", point.date),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(by: .value("Metric", "RMSSD"))
                }

                ForEach(sortedSDNN) { point in
                    LineMark(
                        x: .value("Time", point.date),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(by: .value("Metric", "SDNN"))

                    PointMark(
                        x: .value("Time", point.date),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(by: .value("Metric", "SDNN"))
                }
                
                // Avg RMSSD line
                if avgRMSSD > 0 {
                    RuleMark(
                        y: .value("Avg RMSSD", avgRMSSD)
                    )
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .annotation(position: .top) {
                        Text("Avg RMSSD")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                // Avg SDNN line
                if avgSDNN > 0 {
                    RuleMark(
                        y: .value("Avg SDNN", avgSDNN)
                    )
                    .foregroundStyle(.orange)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .annotation(position: .bottom) {
                        Text("Avg SDNN")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }

            }
            .chartForegroundStyleScale([
                "RMSSD": .green,
                "SDNN": .blue
            ])

        }
    }

    private var maxHRV: Double {
        let allValues = rmssdPoints.map(\.value) + sdnnPoints.map(\.value)
        return max(allValues.max() ?? 100, 100)
    }
    
    private func dailyAverage(of points: [HRVPoint]) -> Double {
        guard !points.isEmpty else { return 0 }
        return points.map { $0.value }.reduce(0, +) / Double(points.count)
    }
    private func baselineAverage(from historical: [HRVPoint]) -> Double {
        guard !historical.isEmpty else { return 0 }
        return historical.map { $0.value }.reduce(0, +) / Double(historical.count)
    }

}



#Preview("More HRV Info Sheet") {
    MoreHRVInfoSheet(
        hrvViewModel: HRVChartViewModel.mock(),
        startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
        endDate: Date(),
        sleepSessions: SleepViewModel.mock().sleepSession.map { [$0] } ?? []
    )
}
