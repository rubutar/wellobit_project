//
//  SleepViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//

import Foundation
import Combine

@MainActor
final class SleepViewModel: ObservableObject {

    enum State {
        case idle
        case loading
        case loaded
        case noData
    }

    @Published var durationText: String = "--"
    @Published var timeRangeText: String = "--"
    @Published var state: State = .idle
    @Published var sleepStages: [SleepStage] = []
    
    @Published var sleepHistory: [DailySleepSummary] = []
    @Published var selectedHistoryRange: SleepHistoryRange = .week
    @Published var sleepAverages: SleepAverages?
    
    @Published private(set) var selectedDate: Date


    private let fetchSleepUseCase: FetchSleepSessionUseCase
    private let fetchSleepStagesUseCase: FetchSleepStagesUseCase
    private let permissionManager = HealthKitPermissionManager()
    private let fetchSleepHistoryUseCase: FetchSleepHistoryUseCase
    private let fetchSleepAveragesUseCase: FetchSleepAveragesUseCase


    init(
        fetchSleepUseCase: FetchSleepSessionUseCase,
        fetchSleepStagesUseCase: FetchSleepStagesUseCase,
        fetchSleepHistoryUseCase: FetchSleepHistoryUseCase,
        fetchSleepAveragesUseCase: FetchSleepAveragesUseCase
    ) {
        self.fetchSleepUseCase = fetchSleepUseCase
        self.fetchSleepStagesUseCase = fetchSleepStagesUseCase
        self.fetchSleepHistoryUseCase = fetchSleepHistoryUseCase
        self.fetchSleepAveragesUseCase = fetchSleepAveragesUseCase
        
//        self.selectedDate = Calendar.current.date(
//            byAdding: .day,
//            value: -1,
//            to: Date()
//        ) ?? Date()
        
        self.selectedDate = Calendar.current.startOfDay(for: Date())


    }
    
    func onAppear() async {
        await loadForSelectedDate()
    }
    
    func goToPreviousDay() {
        selectedDate = Calendar.current.date(
            byAdding: .day,
            value: -1,
            to: selectedDate
        ) ?? selectedDate
    }

    func goToNextDay() {
        let next = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: selectedDate
        ) ?? selectedDate

        guard next <= Date() else { return }
        selectedDate = next
    }


    private func loadForSelectedDate() async {
        state = .loading

        do {
            try await permissionManager.requestSleepPermission()

            guard let session = try await fetchSleepUseCase.execute(
                for: selectedDate
            ) else {
                // ✅ CLEAR stale UI state
                durationText = "No data"
                timeRangeText = "--"
                sleepStages = []
                state = .noData
                return
            }

            durationText = format(duration: session.duration)
            timeRangeText = format(range: session)


            sleepStages = try await fetchSleepStagesUseCase.execute(
                for: selectedDate
            )
            await loadSleepHistory()

            state = .loaded
        } catch {
            state = .noData
        }
    }




//    private func loadSleep() async {
//        do {
//            if let session = try await fetchSleepUseCase.execute() {
//                durationText = format(duration: session.duration)
//                timeRangeText = format(range: session)
//                state = .loaded
//            } else {
//                state = .noData
//            }
//        } catch {
//            state = .noData
//        }
//    }
    
    func loadSleepHistory() async {
        do {
            let history = try await fetchSleepHistoryUseCase.execute(
                range: selectedHistoryRange
            )
            sleepHistory = history

            // ✅ Always compute averages
            let averages = try await fetchSleepAveragesUseCase.execute(
                range: selectedHistoryRange,
                history: history
            )
            sleepAverages = averages

        } catch {
            // ✅ Fallback: still show Avg Sleep
            sleepAverages = SleepAverages(
                averageSleepDuration: sleepHistory
                    .map(\.sleepDuration)
                    .reduce(0, +) / max(1, Double(sleepHistory.count)),
                averageHeartRate: nil,
                averageHRV: nil,
                averageRespiratoryRate: nil
            )
        }
    }




    private func format(duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    private func format(range: SleepSession) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: range.startDate)) – \(formatter.string(from: range.endDate))"
    }
    func selectHistoryRange(_ range: SleepHistoryRange) async {
        guard selectedHistoryRange != range else { return }
        selectedHistoryRange = range
        await loadSleepHistory()
    }
    private func formatSleep(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    private func formatOptional(
        _ value: Double?,
        suffix: String,
        decimals: Int = 0
    ) -> String {
        guard let value else { return "--" }
        return String(format: "%.\(decimals)f%@", value, suffix)
    }
    
//    func debugLoadSleepForSelectedDate() async {
//        print("🔍 DEBUG: loading sleep for", selectedDate)
//
//        do {
//            try await permissionManager.requestSleepPermission()
//
//            let session = try await fetchSleepUseCase.execute(for: selectedDate)
//
//            if let session {
//                print("🛌 Sleep session FOUND")
//                print("   Start:", session.startDate)
//                print("   End:", session.endDate)
//                print("   Duration:", session.duration / 3600, "hours")
//            } else {
//                print("⚠️ No sleep session found")
//            }
//
//        } catch {
//            print("❌ Error fetching sleep:", error)
//        }
//    }


}

extension SleepHistoryRange {
    var timelineStyle: SleepTimelineStyle {
        switch self {
        case .week: return .week
        case .twoWeeks: return .twoWeeks
        case .month: return .month
        case .threeMonths: return .threeMonths
        }
    }
}
