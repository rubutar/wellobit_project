//
//  StressSummaryUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//

import Foundation


final class StressSummaryUseCase {

    private let fetchHRVUseCase: FetchHRVLast24HoursUseCase

    init(fetchHRVUseCase: FetchHRVLast24HoursUseCase) {
        self.fetchHRVUseCase = fetchHRVUseCase
    }

//    func execute(
//        for date: Date,
//        completion: @escaping (Int, StressLevel) -> Void
//    ) {
//        fetchHRVUseCase.execute(for: date) { samples in
//            let values = samples.map(\.value)
//
//            guard !values.isEmpty else {
//                completion(0, .low)
//                return
//            }
//
//            let averageHRV = values.reduce(0, +) / Double(values.count)
//            let score = HRVToStressMapper.stressScore(from: averageHRV)
//            let level = HRVToStressMapper.stressLevel(from: score)
//
//            completion(score, level)
//        }
//    }
    
    func execute(for date: Date) async throws -> (Int, StressLevel) {

        let samples = try await fetchHRVUseCase.execute(for: date)
        let values = samples.map(\.value)

        guard !values.isEmpty else {
            return (0, .low)
        }

        let averageHRV = values.reduce(0, +) / Double(values.count)
        let score = HRVToStressMapper.stressScore(from: averageHRV)
        let level = HRVToStressMapper.stressLevel(from: score)

        return (score, level)
    }

}
