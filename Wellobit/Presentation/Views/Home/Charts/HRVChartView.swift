//
//  HRVChartView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 17/01/26.
//


struct HRVChartView: View {

    let hrvPoints: [HRVPoint]
    let sleepSessions: [SleepSession]
    let startDate: Date
    let endDate: Date

    var body: some View {
        if hrvPoints.isEmpty {
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

                // RMSSD
                ForEach(hrvPoints.filter { $0.type == .rmssd }) { point in
                    PointMark(
                        x: .value("Time", point.date),
                        y: .value("RMSSD", point.value)
                    )
                    .foregroundStyle(.green)
                }

                // SDNN
                ForEach(hrvPoints.filter { $0.type == .sdnn }) { point in
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
        }
    }

    private var maxHRV: Double {
        max(hrvPoints.map(\.value).max() ?? 100, 100)
    }
}
