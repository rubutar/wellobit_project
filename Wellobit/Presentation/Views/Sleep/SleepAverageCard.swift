//
//  SleepAverageCard.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


import SwiftUI

struct SleepAverageCard: View {

    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}