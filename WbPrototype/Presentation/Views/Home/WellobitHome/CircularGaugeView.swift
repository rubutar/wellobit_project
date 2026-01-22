//
//  CircularGaugeView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 20/01/26.
//

import SwiftUI
import RiveRuntime

enum WellbeingZoneEnum: String {
    case low = "Zenny Low Battery"
    case moderate = "Zenny Moderate"
    case balanced = "Zenny Balanced"
    case good = "Zenny Good"
}

private func zone(for score: Int) -> WellbeingZoneEnum {
    switch score {
    case 0..<30:
        return .low
    case 30..<50:
        return .moderate
    case 50..<70:
        return .balanced
    default:
        return .good
    }
}

struct GaugeZone {
    let range: ClosedRange<Int>
    let color: Color
}

struct CircularGaugeView: View {
    let score: Int
    @State private var currentZone: WellbeingZoneEnum = .low

    var body: some View {
        ZStack {
            if score == 0 {
                Image("zenny_no_data")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
            } else {
                RiveViewModel(fileName: currentZone.rawValue)
                    .view()
                    .frame(width: 200, height: 200)
                    .id(currentZone)
            }
            
            SegmentedGaugeView(score: score)            .frame(width: 240, height: 240)
            

        }
        .frame(width: 220, height: 220)
        .onChange(of: score) { newScore in
            currentZone = zone(for: newScore)
        }
        .onAppear {
            currentZone = zone(for: score)
        }
    }
}


struct SegmentedGaugeView: View {
    let score: Int
    
    private let lineWidth: CGFloat = 20
    private let startAngle: Double = 135
    private let sweepAngle: Double = 270
    
    private let zones: [GaugeZone] = [
        .init(range: 0...27, color: Color("low_range")),
        .init(range: 32...47, color: Color("moderate_range")),
        .init(range: 52...67, color: Color("balance_range")),
        .init(range: 72...100, color: Color("good_range"))
    ]
    
    private var indicatorAngle: Double {
        startAngle + sweepAngle * Double(score) / 100
    }
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                ForEach(zones.indices, id: \.self) { index in
                    let zone = zones[index]
                    let start = startAngle + sweepAngle * Double(zone.range.lowerBound) / 100
                    let end   = startAngle + sweepAngle * Double(zone.range.upperBound + 1) / 100
                    
                    Circle()
                        .trim(
                            from: (start - startAngle) / 360,
                            to:   (end - startAngle) / 360
                        )
                        .stroke(
                            zone.color,
                            style: StrokeStyle(
                                lineWidth: lineWidth,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(startAngle))
                }
                
                Circle()
                    .fill(Color.white)
                    .frame(width: lineWidth + 2, height: lineWidth + 2)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.15), lineWidth: 2)
                    )
                    .position(
                        x: size / 2 + cos(indicatorAngle * .pi / 180) * (size / 2),
                        y: size / 2 + sin(indicatorAngle * .pi / 180) * (size / 2)
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    CircularGaugeView(score: 90)
}
