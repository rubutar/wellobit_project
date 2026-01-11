import SwiftUI

struct SleepScoreGaugeView: View {

    let score: Int   // 0–100

    private let lineWidth: CGFloat = 14

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: lineWidth
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    gaugeColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.8), value: score)

            // Center score
            VStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 40, weight: .bold))

                Text("Sleep Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 160, height: 160)
    }

    private var gaugeColor: Color {
        switch score {
        case 85...100: return .green
        case 70..<85: return .blue
        case 50..<70: return .orange
        default: return .red
        }
    }
}
