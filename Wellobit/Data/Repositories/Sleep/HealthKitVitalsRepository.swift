//
//  VitalsRepository.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import HealthKit

protocol VitalsRepository {
    func fetchSleepHR(start: Date, end: Date) async throws -> Double?
    func fetchSleepHRV(start: Date, end: Date) async throws -> Double?

    func fetchBaselineHR(days: Int) async throws -> Double?
    func fetchBaselineHRV(days: Int) async throws -> Double?
}
