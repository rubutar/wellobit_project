//
//  BuildHRStressTimelineUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 12/01/26.
//

import Foundation
import HealthKit

final class BuildHRStressTimelineUseCase {

    private let fetchHRUseCase = FetchRestingHeartRateUseCase()
    private let calendar = Calendar.current

    func execute(
        startDate: Date,
        endDate: Date,
        baselineRHR: Double,
        completion: @escaping ([HRStressPoint]) -> Void
    ) {

        fetchHRUseCase.execute(
            startDate: startDate,
            endDate: endDate
        ) { samples in

            // 1. Sort samples by time
            let sortedSamples = samples.sorted {
                $0.startDate < $1.startDate
            }

            // 2. Group into 10-minute buckets
            let grouped = Dictionary(grouping: sortedSamples) { sample -> Date in
                let components = self.calendar.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: sample.startDate
                )

                let minuteBucket = (components.minute ?? 0) / 10 * 10

                return self.calendar.date(
                    bySettingHour: components.hour ?? 0,
                    minute: minuteBucket,
                    second: 0,
                    of: sample.startDate
                )!
            }

            // 3. Average BPM per bucket and normalize
            let points: [HRStressPoint] = grouped.compactMap { date, samples in
                let avgHR = samples
                    .map {
                        $0.quantity.doubleValue(
                            for: HKUnit.count().unitDivided(by: .minute())
                        )
                    }
                    .reduce(0, +) / Double(samples.count)

                let value = HRStressMapper.normalize(
                    rhr: avgHR,
                    baselineRHR: baselineRHR
                )

                return HRStressPoint(
                    date: date,
                    value: value
                )
            }
            .sorted { $0.date < $1.date }

            completion(points)
        }
    }
}
