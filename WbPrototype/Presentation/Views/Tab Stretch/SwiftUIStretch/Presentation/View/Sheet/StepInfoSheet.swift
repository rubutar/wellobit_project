//
//  StepInfoSheet.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/02/26.
//


import SwiftUI

struct StepInfoSheet: View {
    
    let step: StretchStep
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
//                    Image(step.imageName)
                    Image(systemName: "figure.cooldown")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                    
                    if !step.instructions.isEmpty {
                        SectionHeader(title: "Instructions")
                        BulletList(items: step.instructions)
                    }
                    
                    if !step.tips.isEmpty {
                        SectionHeader(title: "Tips")
                        BulletList(items: step.tips)
                    }
                    
                    if !step.modifications.isEmpty {
                        SectionHeader(title: "Modifications")
                        BulletList(items: step.modifications)
                    }
                    
                    if !step.benefits.isEmpty {
                        SectionHeader(title: "Benefits")
                        BulletList(items: step.benefits)
                    }
                }
                .padding()
            }
            .navigationTitle(step.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
    }
}

struct BulletList: View {
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(item)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
