import SwiftUI

struct InsightsSummaryCards: View {
    let summary: InsightsSummary

    var body: some View {
        HStack(spacing: 12) {
            weekAverageCard
            bestDayCard
        }
    }

    // MARK: - Week average HRV

    private var weekAverageCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Week average HRV")
                .font(.figtree(size: 14, weight: .semibold))
                .foregroundColor(Color.tmFontBlack22)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(summary.averageHRV)")
                    .font(.figtree(size: 28, weight: .semibold))
                    .foregroundColor(Color.tmFontBlack22)
                Text("ms")
                    .font(.figtree(size: 14, weight: .semibold))
                    .foregroundColor(Color.tmGrey92)
            }

            deltaLabel
        }
        .padding(16)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    private var deltaLabel: some View {
        let delta = summary.deltaVsLastWeek
        let (iconName, labelColor, bgColor): (String?, Color, Color) = {
            if delta > 0 {
                return ("arrow_up",
                        Color(red: 0.13, green: 0.64, blue: 0.38),
                        Color(red: 0.13, green: 0.64, blue: 0.38).opacity(0.10))
            } else if delta < 0 {
                return ("arrow_down",
                        Color(red: 0.85, green: 0.25, blue: 0.25),
                        Color(red: 0.85, green: 0.25, blue: 0.25).opacity(0.10))
            } else {
                return (nil,
                        Color.tmFontGray66,
                        Color.tmFontGray66.opacity(0.10))
            }
        }()

        return HStack(spacing: 3) {
            if let icon = iconName {
                Image(icon)
                    .font(.figtree(size: 9, weight: .bold))
            }
            Text(delta == 0 ? "same as last week" : "\(abs(delta))ms vs last week")
                .font(.figtree(size: 11, weight: .semibold))
        }
        .foregroundColor(labelColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Best day

    private var bestDayCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Best Day")
                .font(.figtree(size: 15, weight: .semibold))
                .foregroundColor(Color.tmFontBlack22)

            Text(summary.bestDayName)
                .font(.figtree(size: 28, weight: .semibold))
                .foregroundColor(Color.tmFontBlack22)

            InsightsStatusBadge(label: summary.bestDayStatus.mostlyLabel, status: summary.bestDayStatus, fixedSize: false)
        }
        .padding(16)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }
}

// MARK: - Preview

#Preview("Summary Cards") {
    let summary = InsightsSummary(
        weekStart: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 24))!,
        weekEnd:   Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 30))!,
        averageHRV: 42,
        deltaVsLastWeek: 0,
        bestDayName: "Sat",
        bestDayStatus: .low
    )

    ZStack {
        Color(red: 0.88, green: 0.96, blue: 0.99).ignoresSafeArea()
        InsightsSummaryCards(summary: summary)
            .padding(24)
    }
}
