//
//  FetchHRVLast24HoursUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import Foundation
import HealthKit

final class FetchHRVLast24HoursUseCase {
    
    private let healthKit: HealthKitManager
    
    init(healthKit: HealthKitManager = .shared) {
        self.healthKit = healthKit
    }
    func execute(
        for date: Date,
        completion: @escaping ([HRVSample]) -> Void
    ) {
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
                
        healthKit.fetchHRV(
            startDate: startDate,
            endDate: endDate
        ) { samples in
            
            let mapped: [HRVSample] = samples.map {
                HRVSample(
                    date: $0.startDate,
                    value: $0.quantity.doubleValue(
                        for: HKUnit.secondUnit(with: .milli)
                    )
                )
            }
            
            completion(mapped)
        }
    }
}
