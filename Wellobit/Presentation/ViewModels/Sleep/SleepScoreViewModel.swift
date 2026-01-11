import Foundation

@MainActor
final class SleepScoreViewModel: ObservableObject {

    @Published private(set) var sleepScore: SleepScore?

    private let calculator: SleepScoreCalculating

    init(calculator: SleepScoreCalculating = SleepScoreCalculator()) {
        self.calculator = calculator
    }

    func calculateScore(input: SleepScoreInput) {
        sleepScore = calculator.calculate(input: input)
    }
}
