//
//  StressZoneBreakdownUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//

import Foundation


final class StressZoneBreakdownUseCase {
    
    private let fetchHRVUseCase: FetchHRVLast24HoursUseCase
    
    init(fetchHRVUseCase: FetchHRVLast24HoursUseCase) {
        self.fetchHRVUseCase = fetchHRVUseCase
    }
    
    func execute(
        for date: Date,
        completion: @escaping (StressZoneSummary) -> Void
    ) {
        
        Task {
            do {
                let samples = try await fetchHRVUseCase.execute(for: date)
                
                guard !samples.isEmpty else {
                    completion(
                        StressZoneSummary(
                            low: 0,
                            medium: 0,
                            high: 0,
                            veryHigh: 0
                        )
                    )
                    return
                }
                
                let levels: [StressLevel] = samples.map {
                    let score = HRVToStressMapper.stressScore(from: $0.value)
                    return HRVToStressMapper.stressLevel(from: score)
                }
                
                let total = levels.count
                
                let low = levels.filter { $0 == .low }.count
                let medium = levels.filter { $0 == .medium }.count
                let high = levels.filter { $0 == .high }.count
                let veryHigh = levels.filter { $0 == .veryHigh }.count
                
                completion(
                    StressZoneSummary(
                        low: Int(Double(low) / Double(total) * 100),
                        medium: Int(Double(medium) / Double(total) * 100),
                        high: Int(Double(high) / Double(total) * 100),
                        veryHigh: Int(Double(veryHigh) / Double(total) * 100)
                    )
                )
                
            } catch {
                completion(
                    StressZoneSummary(
                        low: 0,
                        medium: 0,
                        high: 0,
                        veryHigh: 0
                    )
                )
            }
        }
    }    
}

