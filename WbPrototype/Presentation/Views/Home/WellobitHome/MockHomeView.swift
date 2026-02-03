//
//  SleepView.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//
import SwiftUI
import HealthKit

struct MockHomeView: View {
    
    @State private var mockHRArrayText = "10, 20, 30, 40, 50, 60, 70"
    @State private var mockRMSSDArrayText = "10, 20, 30, 40, 50, 60, 70"
    @State private var mockSDNNArrayText = "10, 20, 30, 40, 50, 60, 70"
    @State private var mockCurrentRMSSD: String = "33"
    @State private var mockBaselineRMSSD: String = "33"
    @State private var mockCurrentSDNN: String = "33"
    @State private var mockBaselineSDNN: String = "33"
    @State private var mockCurrentHR: String = "79"
    @State private var mockBaselineHR: String = "79"
    @State private var interpretedState: HRVState?
    @State private var isTestingTrend: Bool = false
    @AppStorage(RestKeys.isResting)
    private var isResting: Bool = true





    
    @State private var showWellbeingInfo = false
    
    @StateObject var viewModel: SleepViewModel
    @StateObject private var stressViewModel = StressViewModel()
    @StateObject private var hrvViewModel: HRVChartViewModel
    @State private var showInfo = false
    @Environment(\.dataMode) private var dataMode

    @ObservedObject var breathingViewModel: BreathingPlayerViewModel
    


    init(
        viewModel: SleepViewModel,
        breathingViewModel: BreathingPlayerViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.breathingViewModel = breathingViewModel
        _viewModel = StateObject(wrappedValue: viewModel)
        let dataSource = HealthKitHRVDataSource(
            healthStore: HKHealthStore()
        )
        let sdnnUseCase = FetchTodayHRVUseCaseImpl(
            hrvDataSource: dataSource
        )
        let rmssdUseCase = FetchTodayRMSSDUseCaseImpl(
            hrvDataSource: dataSource
        )
        let hrDataSource = HealthKitHeartRateDataSource(
            healthStore: HKHealthStore()
        )
        let fetchHRUseCase = FetchTodayHeartRateSamplesUseCaseImpl(
            dataSource: hrDataSource
        )
        let sdnn30 = FetchLast30DaysSDNNUseCaseImpl(dataSource: dataSource)
        let rmssd30 = FetchLast30DaysRMSSDUseCaseImpl(dataSource: dataSource)
        let rhrUseCase = FetchTodayRHRUseCaseImpl(dataSource: dataSource)
        let rhr60 = FetchLast60DaysRHRUseCaseImpl(dataSource: dataSource)
        let calculateScoreUseCase = CalculateDailyScoreUseCaseImpl()
        let calculateCurrentScoreUseCase = CalculateCurrentScoreUseCaseImpl()
        let interpretScoreUseCase = InterpretDailyScoreUseCaseImpl()
        let interpretHRVUseCase = InterpretHRVUseCaseImpl()
        let fetchLatestSnapshotUseCase = FetchLatestHRVSnapshotUseCaseImpl(
            fetchTodayHRVUseCase: sdnnUseCase,
            fetchTodayRMSSDUseCase: rmssdUseCase,
            fetchTodayHeartRateUseCase: fetchHRUseCase
        )
        let fetchHRBaselineUseCase = FetchHRBaselineUseCaseImpl(
            dataSource: hrDataSource
        )
        
        _hrvViewModel = StateObject(
            wrappedValue: HRVChartViewModel(
                fetchSDNNUseCase: sdnnUseCase,
                fetchRMSSDUseCase: rmssdUseCase,
                fetch30DaySDNNUseCase: sdnn30,
                fetch30DayRMSSDUseCase: rmssd30,
                fetchRHRUseCase: rhrUseCase,
                fetch60DayRHRUseCase: rhr60,
                fetchHeartRateUseCase: fetchHRUseCase,
                calculateScoreUseCase: calculateScoreUseCase,
                calculateCurrentScoreUseCase: calculateCurrentScoreUseCase,
                interpretScoreUseCase: interpretScoreUseCase,
                interpretHRVUseCase: interpretHRVUseCase,
                fetchLatestSnapshotUseCase: fetchLatestSnapshotUseCase,
                fetchHRBaselineUseCase: fetchHRBaselineUseCase
            )
        )
    }
    
    init(
        viewModel: SleepViewModel,
        hrvViewModel: HRVChartViewModel,
        breathingViewModel: BreathingPlayerViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _hrvViewModel = StateObject(wrappedValue: hrvViewModel)
        self.breathingViewModel = breathingViewModel
    }

    
    var body: some View {
        let calendar = Calendar.current

        let startDate = calendar.startOfDay(for: viewModel.selectedDate)

        let endDate = calendar.date(
            byAdding: DateComponents(day: 1, second: -1),
            to: startDate
        )!

        
        let interpretation_message = hrvViewModel.currentDetailedExplanation
        let interpretation_label = hrvViewModel.currentInterpretation?.label ?? ""
        
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    HeaderView()
                    WellbeingCardView(
                        score: hrvViewModel.currentScore,
                        status: interpretation_label,
                        description: interpretation_message,
                        onInfoTap: {
                            print(hrvViewModel.dailyScore)
                            showWellbeingInfo = true
                        },
                        hrvViewModel: hrvViewModel,
                        startDate: startDate,
                        endDate: endDate,
                        sleepSessions: viewModel.sleepSession.map { [$0] } ?? [],
                        interpretation: hrvViewModel.currentInterpretation
                    )
                    HStack(spacing: 16) {
                        AvgHRVCardView(
                            title: "Current HRV",
                            value: Int(hrvViewModel.latestSnapshot?.sdnn?.value ?? 0),
                            unit: "ms",
                            time: hrvViewModel.latestSnapshot?.sdnn?.date.hourMinuteString ?? "--",
                            recentAverage: Int(hrvViewModel.baselineSDNNValue),
                            isUp: Int(hrvViewModel.latestSnapshot?.sdnn?.value ?? 0) > Int(hrvViewModel.baselineSDNNValue)
                        )


                        AvgHRVCardView(
                            title: "Current Heart Rate",
                            value: Int(hrvViewModel.latestSnapshot?.heartRate?.bpm ?? 0),
                            unit: "bpm",
                            time: hrvViewModel.latestSnapshot?.heartRate?.date.hourMinuteString ?? "--",
                            recentAverage: Int(hrvViewModel.hrBaseline7Days ?? 0),
                            isUp: Int(hrvViewModel.latestSnapshot?.heartRate?.bpm ?? 0) > Int(hrvViewModel.hrBaseline7Days ?? 0)
                        )

                    }

                    VStack {
                        Button {
                            showInfo = true
                        } label: {
                            Text("More info")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        
                    }
                    .sheet(isPresented: $showInfo) {
                        MoreHRVInfoSheet(
            //                viewModel: SleepViewModel.mock(),
                            hrvViewModel: hrvViewModel,
                            startDate: startDate,
                            endDate: endDate,
                            sleepSessions: []
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if isResting {
                            Text("isRest TRUE")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("isRest FALSE")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
//                        if isResting2 {
//                            Text("isRest TRUE")
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
//                        } else {
//                            Text("isRest FALSE")
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
//                        }
                        let sdnnText = hrvViewModel.sdnnPoints
                            .map { String(format: "%.1f", $0.value) }
                            .joined(separator: ", ")

                        let hrText = hrvViewModel.heartRateSamples
                            .map { String(format: "%.0f", $0.bpm) }
                            .joined(separator: ", ")

                        Text("SDNN: \(sdnnText)")
                            .font(.caption2)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("HR: \(hrText)")
                            .font(.caption2)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }



                    if let snapshot = hrvViewModel.latestSnapshot {
                        LatestHRVSnapshotView(snapshot: snapshot,
                                              hrBaseline7Days: hrvViewModel.hrBaseline7Days,
                                              score: hrvViewModel.currentScore
                                              
                        )
                    }
                    
                }
                .padding(.horizontal)
                .padding(.top)
                // MARK: - Mock Input Panel
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Mock Inputs")
                            .font(.headline)

                        Spacer()

                        Button("Apply Mock Values") {
                            applyMockValues()
                            DispatchQueue.main.async {
                                hrvViewModel.runInterpretation()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Text("ℹ️ Tap the button a few times until the mock data is fully applied.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)

                    mockField("Current HRV RMSSD", text: $mockCurrentRMSSD)
                    mockField("Baseline HRV RMSSD", text: $mockBaselineRMSSD)

                    mockField("Current HRV SDNN", text: $mockCurrentSDNN)
                    mockField("Baseline HRV SDNN", text: $mockBaselineSDNN)

                    mockField("Current Heart Rate", text: $mockCurrentHR)
                    mockField("Baseline Heart Rate", text: $mockBaselineHR)
                    Toggle("Test Trend (HR & HRV arrays)", isOn: $isTestingTrend)
                        .font(.subheadline)
                    Text("Enable this to manually test trend-based interpretation.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isTestingTrend {
                        arrayField("Trend HRV SDNN", text: $mockSDNNArrayText)
                        arrayField("Trend HR", text: $mockHRArrayText)
                    }


                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 4)



                
            }
//            .task(id: viewModel.selectedDate) {
//                do {
//                    try await HealthKitPermissionManager().requestSleepPermission()
//
//                    await hrvViewModel.load(
//                        startDate: startDate,
//                        endDate: endDate
//                    )
//                    await stressViewModel.load(for: viewModel.selectedDate)
//                    await hrvViewModel.loadLatestSnapshot()
//                } catch {
//                    print("HealthKit authorization failed:", error)
//                }
//            }
            .task(id: viewModel.selectedDate) {
                guard !hrvViewModel.isUsingMockData else {
                    print("🧪 Mock mode active — skipping HealthKit load")
                    return
                }

                do {
                    try await HealthKitPermissionManager().requestSleepPermission()

                    await hrvViewModel.load(startDate: startDate, endDate: endDate)
                    await stressViewModel.load(for: viewModel.selectedDate)
                    await hrvViewModel.loadLatestSnapshot()
                } catch {
                    print("HealthKit authorization failed:", error)
                }
            }

            if showWellbeingInfo {
                WellbeingInfoPopup(isPresented: $showWellbeingInfo)
                    .zIndex(10)
            }
        }
        .background(Color(.systemGroupedBackground))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func mockField(_ title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .textFieldStyle(.roundedBorder)
        }
    }

    
    func arrayField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            TextField("e.g. 10, 20, 30, 40, 50", text: text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...5)              // 👈 taller
                .frame(maxWidth: .infinity)   // 👈 wider
                .font(.callout)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
    }

    
    private func applyMockValues() {
        let currentRMSSD = Double(mockCurrentRMSSD) ?? 0
        let baselineRMSSD = Double(mockBaselineRMSSD) ?? 0

        let currentSDNN = Double(mockCurrentSDNN) ?? 0
        let baselineSDNN = Double(mockBaselineSDNN) ?? 0

        let currentHR = Double(mockCurrentHR) ?? 0
        let baselineHR = Double(mockBaselineHR) ?? 0

        // 1️⃣ Apply baselines (safe, controlled)
        hrvViewModel.applyMockBaselines(
            rmssd: baselineRMSSD,
            sdnn: baselineSDNN,
            hr: baselineHR
        )

        // 2️⃣ Apply snapshot (current moment)
        hrvViewModel.applyMockSnapshot(
            rmssd: currentRMSSD,
            sdnn: currentSDNN,
            hr: currentHR
        )

        // 3️⃣ OPTIONAL: apply trend samples (only if provided)
        if isTestingTrend {
            applyMockTrendSamplesIfAny()
        }
    }

    private func applyMockTrendSamplesIfAny() {

        print("🧪 ===== applyMockTrendSamplesIfAny START =====")

        print("🧪 Raw HR text:", mockHRArrayText)
        print("🧪 Raw SDNN text:", mockSDNNArrayText)

        let hrValues = parseValues(mockHRArrayText)
        let sdnnValues = parseValues(mockSDNNArrayText)

        print("🧪 Parsed HR values:", hrValues)
        print("🧪 Parsed SDNN values:", sdnnValues)

        guard !hrValues.isEmpty || !sdnnValues.isEmpty else {
            print("⚠️ No mock trend data provided — EXIT")
            return
        }

        let now = Date()

        if !hrValues.isEmpty {
            let hrSamples = hrValues.enumerated().map { index, bpm in
                HeartRateSample(
                    date: now.addingTimeInterval(TimeInterval(index * 60)),
                    bpm: bpm
                )
            }

            print("🧪 Applying HR samples count:", hrSamples.count)
            hrvViewModel.applyMockHeartRateSamples(hrSamples)
        } else {
            print("⚠️ HR values EMPTY — not applying HR samples")
        }

        if !sdnnValues.isEmpty {
            let hrvPoints = sdnnValues.enumerated().map { index, value in
                HRVPoint(
                    date: now.addingTimeInterval(TimeInterval(index * 60)),
                    value: value,
                    type: .sdnn
                )
            }

            print("🧪 Applying SDNN samples count:", hrvPoints.count)
            hrvViewModel.applyMockHRVPoints(hrvPoints)
        } else {
            print("⚠️ SDNN values EMPTY — not applying HRV samples")
        }

        // 🔥 FINAL STATE CHECK
        print("🔥 ViewModel HR samples:", hrvViewModel.heartRateSamples.count)
        print("🔥 ViewModel SDNN samples:", hrvViewModel.sdnnPoints.count)

        print("🧪 ===== applyMockTrendSamplesIfAny END =====")
    }


    
    private func parseValues(_ text: String) -> [Double] {
        text
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
    }


    private func makeHeartRateSamples(from values: [Double]) -> [HeartRateSample] {
        let start = Date().addingTimeInterval(-Double(values.count) * 60)

        return values.enumerated().map { index, bpm in
            HeartRateSample(
                date: start.addingTimeInterval(TimeInterval(index * 60)),
                bpm: bpm
            )
        }
    }

    private func makeHRVPoints(
        values: [Double],
        type: HRVType
    ) -> [HRVPoint] {

        let start = Date().addingTimeInterval(-Double(values.count) * 60)

        return values.enumerated().map { index, value in
            HRVPoint(
                date: start.addingTimeInterval(TimeInterval(index * 60)),
                value: value,
                type: type
            )
        }
    }
}


