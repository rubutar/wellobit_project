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
        if rmssdPoints.isEmpty && sdnnPoints.isEmpty {
            Text("No HRV data today")
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
                        yEnd: .value("Top", maxHRV)
                    )
                    .foregroundStyle(by: .value("Series", "Sleep"))
                    .opacity(0.15)
                }

                // RMSSD points
                ForEach(rmssdPoints) { point in
                    PointMark(
                        x: .value("Time", point.date),
                        y: .value("RMSSD", point.value)
                    )
                    .foregroundStyle(.green)
                }

                // SDNN points
                ForEach(sdnnPoints) { point in
                    PointMark(
                        x: .value("Time", point.date),
                        y: .value("SDNN", point.value)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .chartXScale(domain: startDate ... endDate)
            .chartYScale(domain: 0...maxHRV)
            .frame(height: 180)
            
            VStack(alignment: .leading, spacing: 6) {

                Text("HRV Summary")
                    .font(.headline)

                let avgRMSSD = dailyAverage(of: rmssdPoints)
                let avgSDNN = dailyAverage(of: sdnnPoints)

//                let baselineAvgRMSSD = dailyAverage(of: hrvViewModel.baselineRMSSD)
//                let baselineAvgSDNN = dailyAverage(of: hrvViewModel.baselineSDNN)

                Text("Daily Average RMSSD: \(Int(avgRMSSD)) ms")
//                Text("Baseline 30 days RMSSD: \(Int(baselineAvgRMSSD)) ms")

                Text("Daily Average SDNN: \(Int(avgSDNN)) ms")
//                Text("Baseline 30 days SDNN: \(Int(baselineAvgSDNN)) ms")
            }
            .padding(.bottom, 8)
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
