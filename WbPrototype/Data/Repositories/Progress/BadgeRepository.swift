//
//  BadgeRepository.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 04/02/26.
//


protocol BadgeRepository {
    func getBadge(for sequence: Int) async -> Badge?
}
