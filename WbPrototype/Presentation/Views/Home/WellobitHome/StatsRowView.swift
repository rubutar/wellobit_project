//
//  StatsRowView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 20/01/26.
//

import SwiftUI


struct StatsRowView: View {
    let dailyAverage: Int
    let baseline: Int
    
    var body: some View {
        HStack(spacing: 16) {
            StatCardView(
                title: "Daily Average",
                value: "\(dailyAverage) ms"
            )
            
            StatCardView(
                title: "Baseline HRV",
                value: "\(baseline) ms"
            )
        }
    }
}
