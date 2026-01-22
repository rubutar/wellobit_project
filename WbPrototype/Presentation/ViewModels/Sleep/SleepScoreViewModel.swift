//
//  SleepScoreViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


import Foundation
import Combine

@MainActor
final class SleepScoreViewModel: ObservableObject {

    @Published var sleepScore: SleepScore?

    private let inputBuilder: SleepScoreInputBuilder
    private let calculator = SleepScoreCalculator()

    init(inputBuilder: SleepScoreInputBuilder) {
        self.inputBuilder = inputBuilder
    }

    func loadSleepScore(for date: Date) async {
        do {
            guard let input = try await inputBuilder.build(for: date) else {
                sleepScore = nil
                return
            }

            sleepScore = calculator.calculate(input: input)
        } catch {
            sleepScore = nil
        }
    }
}
