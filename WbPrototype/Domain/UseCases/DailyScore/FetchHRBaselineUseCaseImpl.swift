//
//  FetchHRBaselineUseCaseImpl.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 29/01/26.
//

import Foundation

protocol FetchHRBaselineUseCase {
    func execute(days: Int) async throws -> Double?
}


final class FetchHRBaselineUseCaseImpl: FetchHRBaselineUseCase {

    private let dataSource: HeartRateDataSource
    private let calendar: Calendar

    init(
        dataSource: HeartRateDataSource,
        calendar: Calendar = .current
    ) {
        self.dataSource = dataSource
        self.calendar = calendar
    }

    func execute(days: Int = 7) async throws -> Double? {
        print("👉 FetchHRBaselineUseCase.execute CALLED")


        let end = Date()
        let start = calendar.date(byAdding: .day, value: -days, to: end)!

        // 👇 PUT DEBUG CODE HERE (TEMPORARY)
         let samples = try? await dataSource.fetchHeartRateSamples(
             startDate: start,
             endDate: end
         )
         print("HR samples in baseline window:", samples?.count ?? 0)
        
        return try await dataSource.fetchAverageHeartRate(
            startDate: start,
            endDate: end
        )
    }
}
