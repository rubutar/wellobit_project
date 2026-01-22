//
//  StatCardView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 20/01/26.
//

import SwiftUI


struct StatCardView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                
                Image(systemName: "info.circle")
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [.red, .yellow, .green],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 6)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}
