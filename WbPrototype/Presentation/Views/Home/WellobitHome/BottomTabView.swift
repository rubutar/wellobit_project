//
//  BottomTabView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 20/01/26.
//

import SwiftUI


struct BottomTabView: View {
    var body: some View {
        HStack {
            TabItem(icon: "house.fill", title: "Home", isActive: true)
            TabItem(icon: "book", title: "Library")
            TabItem(icon: "chart.bar", title: "Analytics")
            TabItem(icon: "sparkles", title: "Insights")
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}

struct TabItem: View {
    let icon: String
    let title: String
    var isActive: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(isActive ? .blue : .gray)
            Text(title)
                .font(.caption)
                .foregroundColor(isActive ? .blue : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}
