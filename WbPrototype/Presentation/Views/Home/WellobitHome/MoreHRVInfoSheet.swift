//
//  EmptyInfoSheet.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 20/01/26.
//

import SwiftUI

struct MoreHRVInfoSheet: View {

    @ObservedObject var hrvViewModel: HRVChartViewModel
    let startDate: Date
    let endDate: Date
    let sleepSessions: [SleepSession]
    
    var body: some View {
        
        ZStack {
            Color.green
                .opacity(0.15)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Text("Today’s Insight")
                        .font(.title2.bold())

                    Text("Based on your average daily data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.clear)

                Divider()

                ScrollView {
                    VStack(spacing: 16) {
                        card {
                            VStack(alignment: .leading, spacing: 8) {
//                                Text("\(hrvViewModel.interpretation?.label ?? "")")
//                                    .font(.system(size: 24, weight: .bold))
                                HorizontalSegmentedGaugeView(score: dailyScore)
                            }
                        }

                        card {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Today's HRV Average")
                                    .font(.headline)
                                
                                LazyVGrid(
                                    columns: [
                                        GridItem(.flexible(), spacing: 12),
                                        GridItem(.flexible(), spacing: 12)
                                    ],
                                    spacing: 12
                                ) {
                                    AvgHRVCardView(
                                        title: "HRV - RMSSD",
                                        value: Int(hrvRMSSDToday),
                                        unit: "ms",
                                        recentAverage: Int(hrvRMSSDBaseline),
                                        isUp: hrvRMSSDToday >= hrvRMSSDBaseline
                                    )
                                    
                                    AvgHRVCardView(
                                        title: "HRV - SDNN",
                                        value: Int(hrvSDNNToday),
                                        unit: "ms",
                                        recentAverage: Int(hrvSDNNBaseline),
                                        isUp: hrvSDNNToday >= hrvSDNNBaseline
                                    )
                                    .gridCellColumns(2)
                                }
                                
                                card {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HRVChartView(
                                            rmssdPoints: hrvViewModel.rmssdPoints,
                                            sdnnPoints: hrvViewModel.sdnnPoints,
                                            sleepSessions: sleepSessions,
                                            startDate: startDate,
                                            endDate: endDate
                                        )
                                        .frame(height: 200)
                                    }
                                }
                            }
                        }


                        card {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Heart Rate")
                                    .font(.headline)
                                
                                AvgHRVCardView(
                                    title: "Resting HR",
                                    value: Int(rhrToday),
                                    unit: "bpm",
                                    recentAverage: Int(rhrBaseline),
                                    isUp: rhrToday <= rhrBaseline // lower is better
                                )

                                card {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HRChartView(
                                            hrSamples: hrvViewModel.heartRateSamples,
                                            avgRHR: Int(rhrBaseline),
                                            sleepSessions: sleepSessions,
                                            startDate: startDate,
                                            endDate: endDate
                                        )
                                    }
                                }
                            }
                        }

                        card {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Daily Summary")
                                    .font(.headline)
                                Text("\(hrvViewModel.interpretation?.label ?? "")")
                                    .font(.subheadline.bold())
                                Text("\(hrvViewModel.detailedExplanation)")
                                .foregroundColor(.secondary)
                            }
                        }
                        Spacer(minLength: 24)
                    }
                    .padding()
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private extension MoreHRVInfoSheet {

    func card<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }

    func comparisonRow(
        title: String,
        today: String,
        baseline: String,
        isBetter: Bool
    ) -> some View {
        HStack {
            Text(title)
                .font(.body.bold())

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Today: \(today)")
                Text("Baseline: \(baseline)")
                    .foregroundColor(.secondary)
            }

            Image(systemName: isBetter ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .foregroundColor(isBetter ? .green : .orange)
        }
        .font(.subheadline)
    }

    func chartPlaceholder(title: String) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6))
            .frame(height: 160)
            .overlay(
                Text(title)
                    .foregroundColor(.secondary)
            )
    }
}

private extension MoreHRVInfoSheet {

    var dailyScore: Int {
        hrvViewModel.dailyScore
    }

    // MARK: - HRV
    var hrvRMSSDToday: Double {
        hrvViewModel.avgRMSSD
    }

    var hrvRMSSDBaseline: Double {
        hrvViewModel.baselineRMSSDValue
    }

    var hrvSDNNToday: Double {
        hrvViewModel.avgSDNN
    }

    var hrvSDNNBaseline: Double {
        hrvViewModel.baselineSDNNValue
    }

    // MARK: - RHR
    var rhrToday: Double {
        hrvViewModel.currentRHRValue
    }

    var rhrBaseline: Double {
        hrvViewModel.baselineAvgRHR
    }
}



//#Preview {
//    HomeView(
//        viewModel: SleepViewModel.mock(),
//        hrvViewModel: HRVChartViewModel.mock()
//    )
//}




#Preview("More HRV Info Sheet") {
    MoreHRVInfoSheet(
        hrvViewModel: HRVChartViewModel.mock(),
        startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
        endDate: Date(),
        sleepSessions: SleepViewModel.mock().sleepSession.map { [$0] } ?? []
    )
}
