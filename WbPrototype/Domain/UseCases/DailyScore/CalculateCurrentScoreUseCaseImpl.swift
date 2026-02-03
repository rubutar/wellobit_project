//
//  CalculateDailyScoreUseCaseImpl.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 18/01/26.
//

protocol CalculateCurrentScoreUseCase {
    func execute(
        currentRMSSD: Double,
        baselineRMSSD: Double,
        currentSDNN: Double,
        baselineSDNN: Double,
        currentHR: Double,
        baselineHR: Double
    ) -> Int
}


final class CalculateCurrentScoreUseCaseImpl: CalculateCurrentScoreUseCase {

    func execute(
        currentRMSSD: Double,
        baselineRMSSD: Double,
        currentSDNN: Double,
        baselineSDNN: Double,
        currentHR: Double,
        baselineHR: Double
    ) -> Int {

        guard baselineRMSSD > 0,
              baselineSDNN > 0,
              currentHR > 0 else {
            return 0
        }

        let rmssdRatio = currentRMSSD / baselineRMSSD
        let sdnnRatio  = currentSDNN / baselineSDNN
        let hrRatio   = baselineHR / currentHR

        func normalize(_ ratio: Double) -> Double {
            return max(0.0, min(ratio, 2.0))
        }

        let weighted =
            (0.45 * normalize(rmssdRatio)) +
            (0.35 * normalize(sdnnRatio)) +
            (0.20 * normalize(hrRatio))

        let score = Int(weighted * 50)

        return max(0, min(score, 100))
    }
}
