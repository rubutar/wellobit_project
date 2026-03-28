import SwiftUI

// MARK: - TimeOfDaySegment presentation extension

extension TimeOfDaySegment {
    var sfSymbol: String {
        switch self {
        case .earlyMorning: return "night"
        case .morning:      return "morning"
        case .afternoon:    return "afternoon"
        case .evening:      return "evening"
        }
    }
}

// MARK: - HRVStatusNew presentation extension

extension HRVStatusNew {
    var badgeTextColor: Color { Color.tmFontBlack22 }

    var mostlyLabel: String {
        switch self {
        case .good:     return "Mostly Good"
        case .balanced: return "Mostly Balanced"
        case .recovery: return "Mostly Recovery"
        case .low:      return "Mostly Low"
        }
    }

    var badgeBorderColor: Color {
        switch self {
        case .good:     return Color.inGood
        case .balanced: return Color.inBalanced
        case .recovery: return Color.inModerate
        case .low:      return Color.inLow
        }
    }

    var badgeBackgroundColor: Color {
        switch self {
        case .good:     return Color.inbgGood
        case .balanced: return Color.inbgBalanced
        case .recovery: return Color.inbgModerate
        case .low:      return Color.inbgLow
        }
    }
    var statusBackgroundColor: Color {
        switch self {
        case .good:     return Color.inbgStGood
        case .balanced: return Color.inbgStBalanced
        case .recovery: return Color.inbgStModerate
        case .low:      return Color.inbgStLow
        }
    }
}

// MARK: - Reusable status badge

struct InsightsStatusBadge: View {
    let label: String
    let borderColor: Color
    let backgroundColor: Color
    var fixedSize: Bool = true

    init(status: HRVStatusNew, fixedSize: Bool = true) {
        label           = status.rawValue
        borderColor     = status.badgeBorderColor
        backgroundColor = status.statusBackgroundColor
        self.fixedSize  = fixedSize
    }

    init(label: String, status: HRVStatusNew, fixedSize: Bool = true) {
        self.label       = label
        borderColor      = status.badgeBorderColor
        backgroundColor  = status.statusBackgroundColor
        self.fixedSize   = fixedSize
    }

    init(label: String, color: Color) {
        self.label           = label
        self.borderColor     = color
        self.backgroundColor = Color.clear
    }

    var body: some View {
        Group {
            if fixedSize {
                Text(label)
                    .font(.figtree(size: 10, weight: .medium))
                    .foregroundColor(Color.tmFontBlack22)
                    .frame(width: 60, height: 20)
            } else {
                Text(label)
                    .font(.figtree(size: 10, weight: .medium))
                    .foregroundColor(Color.tmFontBlack22)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
            }
        }
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - No-reading segment card

private struct NoReadingSegmentCard: View {
    let segment: TimeOfDaySegment

    var body: some View {
        VStack(spacing: 0) {
            Text(segment.segmentTitle)
                .font(.figtree(size: 10, weight: .medium))
                .foregroundColor(Color.tmFontGray66)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32, alignment: .center)
                .padding(.top, 16)
                .padding(.horizontal, 4)

            Spacer()

            Image(segment.sfSymbol)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .opacity(0.3)

            Spacer()

            Text(segment.timeLabel)
                .font(.figtree(size: 9))
                .foregroundColor(Color.tmFontGray66.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)

            Spacer()

            Text("No reading")
                .font(.figtree(size: 10, weight: .medium))
                .foregroundColor(Color.tmFontGray66)
                .frame(width: 60, height: 20)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.tmFontGray66.opacity(0.25), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.tmFontGray66.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Single segment card

private struct SegmentCard: View {
    let seg: TimeOfDayInsight

    var body: some View {
        VStack(spacing: 0) {
            Text(seg.segment.segmentTitle)
                .font(.figtree(size: 10, weight: .medium))
                .foregroundColor(Color.tmFontBlack22)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32, alignment: .center)
                .padding(.top, 16)
                .padding(.horizontal, 4)

            Spacer()

            Image(seg.segment.sfSymbol)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)

            Spacer()

            Text(seg.segment.timeLabel)
                .font(.figtree(size: 9))
                .foregroundColor(Color.tmFontGray66)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)

            Spacer()
            
            InsightsStatusBadge(status: seg.status)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(seg.status.badgeBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(seg.status.badgeBorderColor.opacity(0.45), lineWidth: 1)
        )
    }
}

// MARK: - Day detail card

struct InsightsDayDetailCard: View {
    let insight: DayInsight

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(alignment: .bottom, spacing: 4) {
                    Text(insight.dayName)
                        .font(.figtree(size: 15, weight: .semibold))
                        .foregroundColor(Color.tmFontBlack22)
                    Text(insight.shortDate)
                        .font(.figtree(size: 11))
                        .foregroundColor(Color.tmFontGray66)
                }
                Spacer()
                if insight.avgHRV > 0 {
                    HStack(spacing: 3) {
                        Text("Avg HRV:")
                            .font(.figtree(size: 11))
                            .foregroundColor(Color.tmFontGray66)
                        Text("\(insight.avgHRV)ms")
                            .font(.figtree(size: 14, weight: .bold))
                            .foregroundColor(Color.tmFontBlack22)
                    }
                }
            }
//            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()

            // Always show all 4 segments; white "No reading" card when data is absent
            HStack(spacing: 8) {
                ForEach(TimeOfDaySegment.allCases, id: \.rawValue) { segment in
                    if let seg = insight.segments.first(where: { $0.segment == segment }) {
                        SegmentCard(seg: seg)
                    } else {
                        NoReadingSegmentCard(segment: segment)
                    }
                }
            }
            .frame(height: 158)
            .padding(.vertical, 12)
        }
        .background(Color.tmWhite)
        .padding(.vertical, 8)
        .padding(.horizontal, 18)
    }
}

// MARK: - Preview

#Preview("Day Detail Card") {
    let segments = [
        TimeOfDayInsight(id: UUID(), segment: .earlyMorning, status: .balanced),
        TimeOfDayInsight(id: UUID(), segment: .morning,      status: .balanced),
        TimeOfDayInsight(id: UUID(), segment: .afternoon,    status: .good),
        TimeOfDayInsight(id: UUID(), segment: .evening,      status: .recovery)
    ]
    let insight = DayInsight(
        id: UUID(),
        date: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 31))!,
        avgHRV: 27,
        segments: segments
    )

    ZStack {
        Color.tmWhite.ignoresSafeArea()
        InsightsDayDetailCard(insight: insight)
            .padding(.vertical, 16)
    }
}
