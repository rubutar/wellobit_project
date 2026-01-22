//
//  SleepHistoryBarChart.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//
import SwiftUI

struct SleepHistoryTimelineChart: View {

    let data: [DailySleepSummary]
    let style: SleepTimelineStyle

    private let chartHeight: CGFloat = 120
    private let maxHours: CGFloat = 8
    private let yAxisWidth: CGFloat = 14

    var body: some View {
        GeometryReader { geo in
            let availableWidth = geo.size.width - yAxisWidth
            let slotWidth = availableWidth / CGFloat(style.days)

            HStack(alignment: .bottom, spacing: 0) {

                VStack {
                    yLabel("8h")
                    Spacer()
                    yLabel("4h")
                    Spacer()
                    yLabel("0h")
                }
                .frame(width: yAxisWidth)

                VStack(spacing: 4) {

                    // Timeline
                    HStack(spacing: 0) {
                        ForEach(timeline.indices, id: \.self) { index in
                            let day = timeline[index]
                            let duration = duration(for: day)
                            let valueHeight = lineHeight(for: duration)
                            let emptyHeight = chartHeight - valueHeight - style.dotSize

                            VStack(spacing: 0) {
                                Spacer()
                                    .frame(height: max(0, emptyHeight))

                                Rectangle()
                                    .fill(duration > 0 ? Color.purple : Color.gray.opacity(0.25))
                                    .frame(
                                        width: style.lineWidth,
                                        height: valueHeight
                                    )

                                Circle()
                                    .fill(duration > 0 ? Color.purple : Color.gray.opacity(0.25))
                                    .frame(
                                        width: style.dotSize,
                                        height: style.dotSize
                                    )
                            }
                            .frame(width: slotWidth, height: chartHeight)
                        }
                    }

                    ZStack(alignment: .leading) {
                        ForEach(timeline.indices, id: \.self) { index in
                            if index % style.xLabelInterval == 0 {
                                Text(xLabel(for: timeline[index]))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .position(
                                        x: CGFloat(index) * slotWidth + slotWidth / 2,
                                        y: 6
                                    )
                            }
                        }
                    }
                    .frame(height: 12)
                    .clipped()
                }
            }
        }
        .frame(height: chartHeight + 18)
    }

    // MARK: - Timeline

    private var timeline: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<style.days)
            .reversed()
            .compactMap {
                calendar.date(byAdding: .day, value: -$0, to: today)
            }
    }

    // MARK: - Data

    private func duration(for day: Date) -> TimeInterval {
        data.first {
            Calendar.current.isDate($0.date, inSameDayAs: day)
        }?.sleepDuration ?? 0
    }

    // MARK: - Scaling

    private func lineHeight(for duration: TimeInterval) -> CGFloat {
        let hours = CGFloat(duration / 3600)
        let normalized = min(max(hours / maxHours, 0), 1)
        return normalized * (chartHeight - style.dotSize)
    }

    // MARK: - Labels

    private func xLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = style == .week ? "EEE" : "dd/MM"
        return formatter.string(from: date)
    }

    private func yLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundColor(.secondary)
    }
}
