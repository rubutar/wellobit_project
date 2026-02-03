//
//  LibraryListView.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 01/02/26.
//

import SwiftUI

struct LibraryDetailedView: View {
    
    let session: BreathingSession
    let onStart: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.tmGRGreen.opacity(0),
                    Color.tmGRGreen.opacity(1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                        Text(session.description)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 16)
                    
                    VStack(spacing: 20) {
                        Image(session.diagramImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(20)
                        
                        HStack(alignment: .top, spacing: 8) {
                            //                        Image(systemName: "lightbulb")
                            Text(session.tip)
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                    )
                    .shadow(
                        color: .black.opacity(0.08),
                        radius: 20,
                        y: 10
                    )
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    Button(action: onStart) {
                        Text("Let’s Start")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("ButtonColor"))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.large)
    }
}
