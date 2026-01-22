//
//  MockHeartRateSample.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 19/01/26.
//

import Foundation


struct MockHeartRateSample {
    static func samples(
        values: [Int],
        endDate: Date = Date()
    ) -> [HeartRateSample] {

        let calendar = Calendar.current

        return values.enumerated().map { index, bpm in
            HeartRateSample(
                date: calendar.date(
                    byAdding: .minute,
                    value: -(index * 10),
                    to: endDate
                )!,
                bpm: Double(bpm)
            )
        }
        .reversed()
    }
}
