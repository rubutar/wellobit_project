//
//  StressScoreMapper.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 11/01/26.
//


struct StressScoreMapper {

    static func stressScore(
        hrv: Double,
        baselineHRV: Double
    ) -> Double {

        let ratio = hrv / baselineHRV

        let raw = 100 * (1 - ratio)

        return min(max(raw, 0), 100)
    }
    
    static func stressScore(
        hrv: Double,
        baselineHRV: Double,
        rhr: Double?,
        baselineRHR: Double?
    ) -> Double {

        var stress = stressScore(hrv: hrv, baselineHRV: baselineHRV)

        if let rhr, let baselineRHR {
            let delta = rhr - baselineRHR
            stress += min(max(delta * 6, -15), 20)
        }

        return min(max(stress, 0), 100)
    }

}


