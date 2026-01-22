//
//  CalculateDailyScoreUseCaseImpl.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 18/01/26.
//

protocol CalculateDailyScoreUseCase {
    func execute(
        todayRMSSD: Double,
        baselineRMSSD: Double,
        todaySDNN: Double,
        baselineSDNN: Double,
        todayRHR: Double,
        baselineRHR: Double
    ) -> Int
}


final class CalculateDailyScoreUseCaseImpl: CalculateDailyScoreUseCase {

    func execute(
        todayRMSSD: Double,
        baselineRMSSD: Double,
        todaySDNN: Double,
        baselineSDNN: Double,
        todayRHR: Double,
        baselineRHR: Double
    ) -> Int {

        guard baselineRMSSD > 0,
              baselineSDNN > 0,
              todayRHR > 0 else {
            return 0
        }

        let rmssdRatio = todayRMSSD / baselineRMSSD
        let sdnnRatio  = todaySDNN / baselineSDNN
        let rhrRatio   = baselineRHR / todayRHR

        func normalize(_ ratio: Double) -> Double {
            return max(0.0, min(ratio, 2.0))
        }

        let weighted =
            (0.45 * normalize(rmssdRatio)) +
            (0.35 * normalize(sdnnRatio)) +
            (0.20 * normalize(rhrRatio))

        let score = Int(weighted * 50)

        return max(0, min(score, 100))
    }
}
