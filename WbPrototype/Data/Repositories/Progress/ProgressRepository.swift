//
//  ProgressRepository.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 04/02/26.
//


protocol ProgressRepository {
    func getProgress(currentSequence: Int) async -> [BadgeProgress]
}
