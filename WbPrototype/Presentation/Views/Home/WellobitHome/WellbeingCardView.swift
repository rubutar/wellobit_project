//
//  WellbeingCardView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 20/01/26.
//

import SwiftUI

struct WellbeingZoneInfo: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

let wellbeingZoneInfos: [WellbeingZoneInfo] = [
    .init(
        title: "Low",
        subtitle: "Body’s under stress, take it easy",
        icon: "exclamationmark.triangle.fill",
        color: Color("low_range")
    ),
    .init(
        title: "Recovery",
        subtitle: "System is in recovery mode",
        icon: "bolt.fill",
        color: Color("moderate_range")
    ),
    .init(
        title: "Balanced",
        subtitle: "Healthy stability, normal rhythm",
        icon: "scalemass.fill",
        color: Color("balance_range")
    ),
    .init(
        title: "Calm",
        subtitle: "Well rested, steady rhythm",
        icon: "face.smiling.fill",
        color: Color("good_range")
    )
]


struct WellbeingZone {
    let range: ClosedRange<Int>
    let title: String
    let subtitle: String
    let description: String
    let color: Color
}

let wellbeingZones: [WellbeingZone] = [
    .init(
        range: 0...29,
        title: "Low",
        subtitle: "High stress",
        description: "Your body is under significant strain. Recovery systems are suppressed, often due to poor sleep, stress, illness, or overtraining.",
        color: Color(red: 0.95, green: 0.60, blue: 0.55)
    ),
    .init(
        range: 30...49,
        title: "Moderate",
        subtitle: "Elevated stress",
        description: "Your nervous system is beginning to recover, but stress levels are still higher than ideal. Light movement and quality rest can help restore balance.",
        color: Color(red: 0.98, green: 0.75, blue: 0.55)
    ),
    .init(
        range: 50...69,
        title: "Balanced",
        subtitle: "Recovered",
        description: "Your body is well regulated. Stress and recovery are in balance, supporting consistent energy, focus, and resilience.",
        color: Color(red: 0.75, green: 0.85, blue: 0.65)
    ),
    .init(
        range: 70...100,
        title: "Good",
        subtitle: "Optimal state",
        description: "Your nervous system is performing optimally. This is a strong state for performance, learning, and adaptation.",
        color: Color(red: 0.55, green: 0.78, blue: 0.70)
    )
]




struct WellbeingCardView: View {
    let score: Int
    let status: String
    let description: String
    let onInfoTap: () -> Void
    let hrvViewModel: HRVChartViewModel
    let startDate: Date
    let endDate: Date
    let sleepSessions: [SleepSession]
    
    @State private var showInfo = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack () {
                Text("Your Wellbeing Score")
                    .font(.headline)
                
                Button(action: onInfoTap) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.bottom)
            
            CircularGaugeView(score: score)
            
            Text(status)
//                .font(.headline)
                .font(.system(size: 24, weight: .bold))

            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            if score != 0 {
                Button {
                    showInfo = true
                } label: {
                    Text("More info")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .sheet(isPresented: $showInfo) {
            MoreHRVInfoSheet(
//                viewModel: SleepViewModel.mock(),
                hrvViewModel: hrvViewModel,
                startDate: startDate,
                endDate: endDate,
                sleepSessions: sleepSessions
            )
        }
    }
}


struct WellbeingZoneInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: Formula explanation
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How your score is calculated")
                            .font(.headline)
                        
                        Text("""
    Your Wellbeing Score ranges from 0 to 100 and reflects how well your nervous system is recovering.
    
    It is derived from:
    • Heart Rate Variability (HRV)
    • Resting Heart Rate
    • Sleep consistency
    • Recovery trends over time
    
    Higher scores indicate better autonomic balance and recovery.
    """)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // MARK: Zones
                    Text("Score zones")
                        .font(.headline)
                    
                    ForEach(wellbeingZones, id: \.title) { zone in
                        ZoneRowView(zone: zone)
                    }
                }
                .padding()
            }
            .navigationTitle("Wellbeing Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}


struct ZoneRowView: View {
    let zone: WellbeingZone
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(zone.color)
                .frame(width: 12, height: 12)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(zone.title) • \(zone.range.lowerBound)–\(zone.range.upperBound)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(zone.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(zone.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct WellbeingInfoPopup: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Card
            VStack(spacing: 16) {
                header
                description
                zones
            }
            .padding()
            .background(Color(red: 0.92, green: 0.97, blue: 0.99))
            .cornerRadius(20)
            .padding(.horizontal, 24)
        }
        .transition(.opacity)
        .animation(.easeOut(duration: 0.2), value: isPresented)
        .frame(maxWidth: .infinity, maxHeight: .infinity) 

    }
    
}

private extension WellbeingInfoPopup {
    var header: some View {
        HStack {
            Text("Your Wellbeing Score")
                .font(.headline)

            Spacer()

            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
                    .padding(8)
            }
        }
    }
}
private extension WellbeingInfoPopup {
    var description: some View {
        Text(
            "Think of HRV as your body’s daily readiness check. Here’s how to read it and how to respond."
        )
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.leading)
    }
}

private extension WellbeingInfoPopup {
    var zones: some View {
        VStack(spacing: 12) {
            ForEach(wellbeingZoneInfos) { zone in
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(zone.color)
                            .frame(width: 44, height: 44)

                        Image(systemName: zone.icon)
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(zone.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(zone.subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(14)
            }
        }
    }
}



//#Preview {
//    HomeView()
//}
