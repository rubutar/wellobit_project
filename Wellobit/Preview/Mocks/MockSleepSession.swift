//
//  MockSleepSession.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 19/01/26.
//

import Foundation

//extension SleepSession {
//    static var mock: SleepSession {
//        let end = Date()
//        let start = Calendar.current.date(byAdding: .hour, value: -7, to: end)!
//
//        return SleepSession(
//            startDate: start,
//            endDate: end,
//            duration: 7 * 3600
//        )
//    }
//}

extension SleepSession {
    static var mock: SleepSession {

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let start = calendar.date(
            byAdding: .minute,
            value: 30,          // 00:30
            to: today
        )!

        let end = calendar.date(
            byAdding: .hour,
            value: 6,
            to: start
        )!                     // 06:30

        return SleepSession(
            startDate: start,
            endDate: end,
            duration: 6 * 3600
        )
    }
}
