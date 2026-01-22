//
//  EmptyRMSSDUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 19/01/26.
//

import Foundation

struct EmptyRMSSDUseCase: FetchTodayRMSSDUseCase {
    func execute() async throws -> [HRVPoint] {
        return []
    }
    
    
//    let values: [Double]
//
//    func execute() async throws -> [HRVPoint] {
//        let now = Date()
//        return values.enumerated().map { index, value in
//            HRVPoint(
//                date: Calendar.current.date(
//                    byAdding: .minute,
//                    value: index * 10,
//                    to: now
//                )!,
//                value: value,
//                type: .rmssd
//            )
//        }
//    }
    
}

struct EmptySDNNUseCase: FetchTodayHRVUseCase {
    func execute() async throws -> [HRVPoint] {
        return []
    }
}

struct EmptyHeartRateUseCase: FetchTodayHeartRateSamplesUseCase {
    func execute(
        startDate: Date,
        endDate: Date
    ) async throws -> [HeartRateSample] {
        []
    }
}
struct Empty30DaySDNNUseCase: FetchLast30DaysSDNNUseCase {
    func execute() async throws -> [HRVPoint] {
        return []
    }
}
struct Empty30DayRMSSDUseCase: FetchLast30DaysRMSSDUseCase {
    func execute() async throws -> [HRVPoint] {
        return []
    }
}
struct EmptyRHRUseCase: FetchTodayRHRUseCase {
    func execute() async throws -> Double? {
        return 0
    }
}
struct EmptyRHRHistoryUseCase: FetchLast60DaysRHRUseCase {
    func execute() async throws -> [Double] {
        return []
    }
}
