//
//  FetchLatestHRVSnapshotUseCaseImpl.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 29/01/26.
//

import Foundation

protocol FetchLatestHRVSnapshotUseCase {
    func execute() async throws -> HRVSnapshot
}

final class FetchLatestHRVSnapshotUseCaseImpl: FetchLatestHRVSnapshotUseCase {

    private let fetchTodayHRVUseCase: FetchTodayHRVUseCase
    private let fetchTodayRMSSDUseCase: FetchTodayRMSSDUseCase
    private let fetchTodayHeartRateUseCase: FetchTodayHeartRateSamplesUseCase
    private let calendar: Calendar

    init(
        fetchTodayHRVUseCase: FetchTodayHRVUseCase,
        fetchTodayRMSSDUseCase: FetchTodayRMSSDUseCase,
        fetchTodayHeartRateUseCase: FetchTodayHeartRateSamplesUseCase,
        calendar: Calendar = .current
    ) {
        self.fetchTodayHRVUseCase = fetchTodayHRVUseCase
        self.fetchTodayRMSSDUseCase = fetchTodayRMSSDUseCase
        self.fetchTodayHeartRateUseCase = fetchTodayHeartRateUseCase
        self.calendar = calendar
    }

    func execute() async throws -> HRVSnapshot {

        // 1️⃣ Fetch today’s data in parallel
        async let sdnnPoints = fetchTodayHRVUseCase.execute()
        async let rmssdPoints = fetchTodayRMSSDUseCase.execute()

        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        async let heartRates = fetchTodayHeartRateUseCase.execute(
            startDate: start,
            endDate: end
        )

        let (sdnn, rmssd, hrSamples) = try await (
            sdnnPoints,
            rmssdPoints,
            heartRates
        )

        // 2️⃣ Find latest HRV points
        let latestSDNN = sdnn.max(by: { $0.date < $1.date })
        let latestRMSSD = rmssd.max(by: { $0.date < $1.date })

        // 3️⃣ Choose HRV anchor date
        let anchorDate =
            latestSDNN?.date ??
            latestRMSSD?.date

        // 4️⃣ Find closest HR sample
        let closestHR: HeartRateSample?
        if let anchorDate {
            closestHR = hrSamples.min(by: {
                abs($0.date.timeIntervalSince(anchorDate)) <
                abs($1.date.timeIntervalSince(anchorDate))
            })
        } else {
            closestHR = nil
        }

        // 5️⃣ Return snapshot
        return HRVSnapshot(
            sdnn: latestSDNN,
            rmssd: latestRMSSD,
            heartRate: closestHR
        )
    }
}
