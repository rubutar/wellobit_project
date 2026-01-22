//
//  FetchHRVLast24HoursUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//

import Foundation

final class FetchHRVLast24HoursUseCase {

    private let hrvDataSource: HRVDataSource

    init(hrvDataSource: HRVDataSource) {
        self.hrvDataSource = hrvDataSource
    }

    func execute(for date: Date) async throws -> [HRVSample] {
        let endDate = Calendar.current.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: date
        ) ?? date

        let startDate = Calendar.current.date(
            byAdding: .hour,
            value: -24,
            to: endDate
        )!

        let points = try await hrvDataSource.fetchHRVRange(
            startDate: startDate,
            endDate: endDate
        )

        return points.map {
            HRVSample(
                date: $0.date,
                value: $0.value
            )
        }
    }
}

