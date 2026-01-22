//
//  StressTimelineUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//

import Foundation


final class StressTimelineUseCase {

    private let fetchHRVUseCase: FetchHRVLast24HoursUseCase

    init(fetchHRVUseCase: FetchHRVLast24HoursUseCase) {
        self.fetchHRVUseCase = fetchHRVUseCase
    }

    func execute(
        for date: Date,
        completion: @escaping ([StressTimelinePoint]) -> Void
    ) {
        Task {
            do {
                let samples = try await fetchHRVUseCase.execute(for: date)

                let timeline: [StressTimelinePoint] = samples.map {
                    let score = HRVToStressMapper.stressScore(from: $0.value)
                    let level = HRVToStressMapper.stressLevel(from: score)

                    return StressTimelinePoint(
                        date: $0.date,
                        stressScore: score,
                        stressLevel: level
                    )
                }

                completion(timeline)
            } catch {
                completion([])
            }
        }
    }

}
