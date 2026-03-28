import SwiftUI


// MARK: - HRVQuality bar gradient

extension HRVQuality {
    var barGradientColors: [Color] {
        switch self {
        case .good:     return [Color.inGood, Color.tmWhite]
        case .balanced: return [Color.inBalanced, Color.tmWhite]
        case .recovery: return [Color.inModerate, Color.tmWhite]
        case .low:      return [Color.inLow, Color.tmWhite]
        }
    }
}

// MARK: - Chart container

struct InsightsBarChart: View {
    let entries: [HRVEntry]
    let selectedId: UUID?
    let onSelect: (HRVEntry) -> Void

    /// The tallest bar is always exactly this many points.
    private let maxBarHeight: CGFloat = 160

    private var maxValue: Int {
        max(entries.map(\.value).max() ?? 1, 1)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                ForEach(entries) { entry in
                    let normalised = CGFloat(entry.value) / CGFloat(maxValue)
                    BarColumn(
                        entry: entry,
                        normalised: normalised,
                        maxBarHeight: maxBarHeight,
                        isSelected: entry.id == selectedId,
                        onTap: { onSelect(entry) }
                    )
                }
            }
            .padding(.horizontal, 6)
            .padding(.top, 8)
            .padding(.bottom, 4)

            HRVLegend()
                .padding(.horizontal, 12)
//                .padding(.bottom, 12)
        }
    }
}

// MARK: - Legend

private struct HRVLegend: View {
    private let items: [(label: String, color: Color)] = [
        ("Low",      Color.inLow),
        ("Moderate", Color.inModerate),
        ("Balanced", Color.inBalanced),
        ("Good",     Color.inGood)
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.label) { item in
                HStack(spacing: 4) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 8, height: 8)
                    Text(item.label)
                        .font(.figtree(size: 11, weight: .medium))
                        .foregroundColor(Color.tmFontGray66)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 17)
    }
}

// MARK: - Single bar column

private struct BarColumn: View {
    let entry: HRVEntry
    let normalised: CGFloat     // 0…1
    let maxBarHeight: CGFloat
    let isSelected: Bool
    let onTap: () -> Void

    private let cornerRadius: CGFloat = 9
    private let glassBadgeHeight: CGFloat = 40

    /// Height of the coloured bar for this entry, ceiled to a whole point.
    private var barHeight: CGFloat {
        ceil(normalised * maxBarHeight)
    }

    /// Visible height of the bar ZStack — at least glassBadgeHeight so the day
    /// label badge always shows even when value = 0.
    private var effectiveBarHeight: CGFloat {
        max(barHeight, glassBadgeHeight)
    }

    /// Clear gap above the bar so all columns share the same total height.
    private var topSpacerHeight: CGFloat {
        maxBarHeight - effectiveBarHeight
    }

    var body: some View {
        // VStack with all explicit frame heights — zero layout inference.
        // ms label (fixed 16 pt)  +  clear spacer (variable)  +  bar (variable)
        // sum is always: 16 + 6 + maxBarHeight = fixed for every column.
        VStack(spacing: 0) {
            // ms label — bold when selected; hidden when no data
            Text(entry.value > 0 ? "\(entry.value)ms" : "")
                .font(.figtree(size: 9, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? Color.tmFontBlack22 : Color.tmFontGray66)
                .frame(height: 16)

            // gap between label and bar top
            Color.clear.frame(height: 6)

            // transparent spacer that fills the empty space above shorter bars
            Color.clear.frame(height: topSpacerHeight)

            // Coloured bar
            ZStack(alignment: .bottom) {
                // 1. Gradient base — only when there is data
                if barHeight > 0 {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: entry.quality.barGradientColors,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: barHeight)
                }

                // 2. Glass badge with day label
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius - 3)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.1),
                                        Color.clear,
                                        Color.black.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                    .overlay(alignment: .bottom) {
                        VStack(spacing: 1) {
                            Text(entry.dayAbbreviation)
                                .font(.figtree(size: 9, weight: .medium))
                                .foregroundColor(Color.tmFontGray66)
                            Text(entry.dayNumber)
                                .font(.figtree(size: 16, weight: .medium))
                                .foregroundColor(Color.tmFontBlack22)
                        }
                        .padding(.bottom, 8)
                    }
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .frame(height: 40)
            }
            .frame(height: effectiveBarHeight)
            .scaleEffect(isSelected ? 1.04 : 1.0, anchor: .bottom)
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isSelected)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Preview

#Preview {
    let calendar = Calendar.current
    let today = Date()
    let entries: [HRVEntry] = zip(
        [30, 30, 0, 30, 30, 30, 30],
        [HRVQuality.low, .low, .recovery, .balanced, .balanced, .balanced, .balanced]
    ).enumerated().map { index, pair in
        HRVEntry(
            id: UUID(),
            date: calendar.date(byAdding: .day, value: index, to: today) ?? today,
            value: pair.0,
            quality: pair.1
        )
    }

    ZStack {
        Color(red: 0.88, green: 0.96, blue: 0.99).ignoresSafeArea()
        InsightsBarChart(
            entries: entries,
            selectedId: entries[4].id,
            onSelect: { _ in }
        )
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }
}
