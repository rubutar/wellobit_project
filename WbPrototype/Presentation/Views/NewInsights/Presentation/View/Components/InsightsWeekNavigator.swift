import SwiftUI

struct InsightsWeekNavigator: View {
    let dateRange: String
    let onPrevious: () -> Void
    let onNext: () -> Void
    let canGoNext: Bool

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.figtree(size: 14, weight: .semibold))
                    .foregroundColor(Color.tmFontBlack22)
                    .frame(width: 30, height: 30)
            }
            .background(Color.tmWhite)
            .clipShape(Ellipse())



            Spacer()

            Text(dateRange)
                .font(.figtree(size: 14, weight: .medium))
                .foregroundColor(Color.tmFontBlack22)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.figtree(size: 14, weight: .semibold))
                    .foregroundColor(canGoNext ? Color.tmFontBlack22 : Color.tmFontBlack22.opacity(0.3))
                    .frame(width: 30, height: 30)
            }
            .disabled(!canGoNext)
            .background(Color.tmWhite)
            .clipShape(Ellipse())
        }
        .frame(height: 30)
        .padding(.horizontal, 3)
        .padding(.vertical, 3)
        .background(Color.bgBlue)
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        InsightsWeekNavigator(
            dateRange: "31/03/2025 - 06/04/2025",
            onPrevious: {},
            onNext: {},
            canGoNext: false
        )
        .padding(.horizontal, 24)
    }
}
