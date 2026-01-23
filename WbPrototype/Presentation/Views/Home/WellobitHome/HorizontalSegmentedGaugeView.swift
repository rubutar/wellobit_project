//
//  HorizontalSegmentedGaugeView.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 23/01/26.
//

import SwiftUI

struct HorizontalSegmentedGaugeView: View {
    let score: Int

    private let barHeight: CGFloat = 14
    private let indicatorSize: CGFloat = 28
    private let indicatorStroke: CGFloat = 6


    private let zones: [GaugeZone] = [
        .init(range: 0...27, color: Color("low_range")),
        .init(range: 28...47, color: Color("moderate_range")),
        .init(range: 48...67, color: Color("balance_range")),
        .init(range: 68...100, color: Color("good_range"))
    ]

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width - 20

            HStack(spacing: 6) {
                ForEach(zones.indices, id: \.self) { index in
                    let zone = zones[index]
                    let segmentWidth =
                        CGFloat(zone.range.count) / 100 * width

                    Capsule()
                        .fill(zone.color)
                        .frame(width: segmentWidth, height: barHeight)
                }
            }
            .overlay(alignment: .leading) {

                // ✅ Indicator is now aligned to the BAR, not the container
//                Circle()
//                    .fill(Color.white)
//                    .frame(width: indicatorSize, height: indicatorSize)
//                    .overlay(
//                        Circle()
//                            .stroke(Color.black.opacity(0.15), lineWidth: 2)
//                    )
//                    .offset(
//                        x: indicatorX(totalWidth: width) - indicatorSize / 2
//                    )
//                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
//                    .animation(.easeInOut(duration: 0.3), value: score)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: indicatorSize, height: indicatorSize)
                    .overlay(
                        Circle()
                            .stroke(activeZoneColor(for: score), lineWidth: indicatorStroke)
                    )
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.08))
                            .blur(radius: 4)
                            .scaleEffect(1.2)
                    )
                    .position(
                        x: indicatorX(totalWidth: width),
                        y: barHeight / 2
                    )
                    .animation(.easeInOut(duration: 0.3), value: score)

            }
        }
        .frame(height: barHeight)
        .padding(.horizontal, 12)

    }

    private func indicatorX(totalWidth: CGFloat) -> CGFloat {
        let clampedScore = min(max(score, 0), 100)
        return CGFloat(clampedScore) / 100 * totalWidth
    }
    private func activeZoneColor(for score: Int) -> Color {
        zones.first(where: { $0.range.contains(score) })?.color
            ?? Color.gray
    }
}


#Preview {
    VStack(spacing: 24) {
        HorizontalSegmentedGaugeView(score: 20)
        HorizontalSegmentedGaugeView(score: 45)
        HorizontalSegmentedGaugeView(score: 65)
        HorizontalSegmentedGaugeView(score: 85)
    }
    .padding()
}
