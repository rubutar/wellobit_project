//
//  AvgHRVCardView.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 22/01/26.
//

enum TrendDirection {
    case up
    case down
    case same
}

import SwiftUI

struct AvgHRVCardView: View {
    
    let title: String
    let value: Int
    let unit: String
    let recentAverage: Int
    let isUp: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                Text(title)
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
//                Image(systemName: "info.circle")
//                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 4) {
                trendView(
                    value: value,
                    recentAverage: recentAverage
                )
                    .font(.caption2)
                
                Text("baseline \(recentAverage)\(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
    

    private var trend: TrendDirection {
        if value > recentAverage {
            return .up
        } else if value < recentAverage {
            return .down
        } else {
            return .same
        }
    }
    
    @ViewBuilder
    private func trendView(
        value: Int,
        recentAverage: Int
    ) -> some View {
        if value > recentAverage {
            Image(systemName: "arrowtriangle.up.fill")
                .font(.caption2)
                .foregroundColor(.green)

        } else if value < recentAverage {
            Image(systemName: "arrowtriangle.down.fill")
                .rotationEffect(.degrees(180))
                .font(.caption2)
                .foregroundColor(.red)

        } else {
            Image(systemName: "minus")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    HomeView(
        viewModel: SleepViewModel.mock()
//        hrvViewModel: HRVChartViewModel.mock()
    )
}

