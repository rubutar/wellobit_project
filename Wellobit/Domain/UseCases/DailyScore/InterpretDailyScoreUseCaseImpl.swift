//
//  InterpretDailyScoreUseCaseImpl.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 18/01/26.
//

protocol InterpretDailyScoreUseCase {
    func execute(score: Int) -> String
}


final class InterpretDailyScoreUseCaseImpl: InterpretDailyScoreUseCase {

    func execute(score: Int) -> String {
        switch score {
        case 80...100:
            return "Excellent recovery"
        case 65..<80:
            return "Good readiness"
        case 45..<65:
            return "Normal day"
        case 30..<45:
            return "Below baseline"
        default:
            return "Low recovery – take it easy"
        }
    }
}
