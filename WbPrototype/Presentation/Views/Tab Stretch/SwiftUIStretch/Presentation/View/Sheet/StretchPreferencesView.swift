//
//  StretchPreferencesView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 01/03/26.
//

import SwiftUI

struct StretchPreferencesView: View {
    @AppStorage("stepIntervalTime") private var stepIntervalTime: Int = 3
    
    var body: some View {
        Text("Here will be the Settings")
        
        VStack(alignment: .leading) {
            Text("Interval Between Steps")
                .font(.headline)
            
            Stepper(
                "\(stepIntervalTime) sec",
                value: $stepIntervalTime,
                in: 0...30,
                step: 1
            )
        }
        .padding()
    }
}
