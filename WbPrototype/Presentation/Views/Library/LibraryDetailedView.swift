//
//  LibraryListView.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 01/02/26.
//

import SwiftUI

struct LibraryDetailedView: View {
    
    @State var showPreSessionModal = false
    @ObservedObject var playerViewModel: BreathingPlayerViewModel

    let session: BreathingSession
    let onStart: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.tmGRYellow,
                    Color.tmGRGreen
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
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
                    
                    Button(action: {
//                        if playerViewModel.isPaused {
//                            playerViewModel.showPreSessionModal = false
//                        } else {
                        playerViewModel.showPreSessionModal = true
//                            onStart()
//                        }
                    }) {
                        Text("Let’s Start")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("ThemeColor"))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            
            
            if playerViewModel.showPreSessionModal {
                        MindfulnessOverlay(
                            onConfirm: {
                                playerViewModel.showPreSessionModal = false
//                                playerViewModel.resume()
                                onStart()
                            },
                            onClose: {
                                playerViewModel.showPreSessionModal = false
                            }
                        )
                    }
            }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.large)
//        .onAppear {
//            if playerViewModel.isPaused {
//                playerViewModel.showPreSessionModal = true
//            }
//        }
    }
}
