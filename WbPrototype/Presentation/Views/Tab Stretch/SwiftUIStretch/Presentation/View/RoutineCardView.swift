//
//  RoutineCardView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/02/26.
//

import SwiftUI

struct RoutineCardView: View {
    
    let routine: StretchRoutine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text(routine.title)
                .font(.title3.bold())
            
//            Text(routine.description)
//                .font(.body)
//                .foregroundColor(.secondary)
//                .lineLimit(3)
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                
                Text("\(routine.totalDurationInMinutes) min")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(width: 400, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10)
        )
        
    }
}
