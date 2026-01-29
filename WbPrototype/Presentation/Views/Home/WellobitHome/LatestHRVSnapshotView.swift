//
//  LatestHRVSnapshotView.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 29/01/26.
//

import SwiftUI


struct LatestHRVSnapshotView: View {

    let snapshot: HRVSnapshot
    let hrBaseline7Days: Double?

    var body: some View {
        VStack(spacing: 8) {
            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latest HRV")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let sdnn = snapshot.sdnn {
                        Text("SDNN \(Int(sdnn.value)) ms")
                            .font(.headline)
                        Text(sdnn.date.formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    if let rmssd = snapshot.rmssd {
                        Text("RMSSD \(Int(rmssd.value)) ms")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(rmssd.date.formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Heart Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let hr = snapshot.heartRate {
                        Text("\(Int(hr.bpm)) bpm")
                            .font(.headline)

                        Text(hr.date.formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("Baseline")
                            .font(.caption)
                            .foregroundColor(.secondary)

//                        Text("\(Int(hrBaseline7Days)) bpm")
//                            .font(.headline)

                        if let baseline = hrBaseline7Days {
                            Text("7-day avg \(Int(baseline)) bpm")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
//
//                        if let delta = hrDelta {
//                            Text(delta >= 0
//                                 ? "+\(Int(delta)) bpm vs baseline"
//                                 : "\(Int(delta)) bpm vs baseline")
//                                .font(.caption2)
//                                .foregroundColor(delta > 0 ? .orange : .green)
//                        }

                    } else {
                        Text("—")
                            .font(.headline)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
//    private var hrDelta: Double? {
//        guard
//            let currentHR = snapshot.heartRate?.bpm,
//            let baseline = hrBaseline7Days
//        else { return nil }
//
//        return currentHR - baseline
//    }
}
