//
//  MockHRVPoint.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 19/01/26.
//

import Foundation

extension HRVPoint {
//    static func mockRMSSD(_ values: [Double]) -> [HRVPoint] {
//        values.enumerated().map { index, value in
//            HRVPoint(
//                date: Calendar.current.date(byAdding: .minute, value: index * 10, to: Date())!,
//                value: value,
//                type: .rmssd
//            )
//        }
//    }
    
    static func mockRMSSDHourly(
        values: [Double],
        endDate: Date = Date()
    ) -> [HRVPoint] {
        
        let calendar = Calendar.current
        
        return values.enumerated().map { index, value in
            HRVPoint(
                date: calendar.date(
                    byAdding: .hour,
                    value: -index,
                    to: endDate
                )!,
                value: value,
                type: .rmssd
            )
        }
        .reversed() // chronological order
    }
    
    static func mockSDNN(
        values: [Double],
        endDate: Date = Date()
    ) -> [HRVPoint] {
        
        let calendar = Calendar.current
        
        return values.enumerated().map { index, value in
            HRVPoint(
                date: calendar.date(
                    byAdding: .hour,
                    value: -index,
                    to: endDate
                )!,
                value: value,
                type: .rmssd
            )
        }
        .reversed() // chronological order
    }
    
//    static func mockSDNN(_ values: [Double]) -> [HRVPoint] {
//        values.enumerated().map { index, value in
//            HRVPoint(
//                date: Calendar.current.date(byAdding: .minute, value: index * 10, to: Date())!,
//                value: value,
//                type: .sdnn
//            )
//        }
//    }
}
