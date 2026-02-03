//
//  Date+StartOfDay.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 02/02/26.
//

import Foundation

extension Date {
    static func startOfToday() -> Date {
        Calendar.current.startOfDay(for: Date())
    }
}
