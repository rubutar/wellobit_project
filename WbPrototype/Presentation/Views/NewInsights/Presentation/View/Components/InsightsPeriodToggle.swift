import SwiftUI

struct InsightsPeriodToggle: View {
    @Binding var selectedPeriod: InsightPeriod
    private let periods: [InsightPeriod] = InsightPeriod.allCases

    var body: some View {
        HStack(spacing: 0) {
            ForEach(periods, id: \.self) { (period: InsightPeriod) in
                PeriodButton(
                    period: period,
                    isSelected: selectedPeriod == period,
                    action: { selectedPeriod = period }
                )
            }
        }
        .padding(4)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.06), radius: 8, y: 2)
        .animation(.easeInOut(duration: 0.2), value: selectedPeriod)
    }
}

private struct PeriodButton: View {
    let period: InsightPeriod
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            PeriodLabel(title: period.rawValue, isSelected: isSelected)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.tmBlue : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct PeriodLabel: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(Font.system(size: 15, weight: .medium))
            .foregroundColor(isSelected ? Color.white : Color.tmFontGray66)
    }
}
