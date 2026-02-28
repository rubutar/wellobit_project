//
//  StretchRepository.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/02/26.
//


import Foundation

protocol StretchRepository {
    func fetchRoutines() async throws -> [StretchRoutine]
}