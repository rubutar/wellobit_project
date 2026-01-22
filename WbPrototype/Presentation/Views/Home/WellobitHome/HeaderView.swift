//
//  HeaderView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 20/01/26.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good morning")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Rudi")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Image(systemName: "chart.xyaxis.line")
                Image(systemName: "gearshape")
            }
            .font(.title3)
            .foregroundColor(.primary)
        }
    }
}
