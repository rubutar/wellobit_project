//
//  DailyStressSummaryBuilder.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 28/01/26.
//


import SwiftUI

struct DailyStressSummary {
    let title: String
    let body: String
    let accentColor: Color
}

enum DailyStressSummaryBuilder {

    static func build(
        peakStress: Double?,
        sleepScore: Int?
    ) -> DailyStressSummary {

        let title: String
        let stressText: String
        let color: Color

        if let peakStress {
            switch peakStress {
            case 0..<25:
                title = "A Calm Day"
                stressText = "Your stress levels stayed low for most of the day."
                color = .green
            case 25..<50:
                title = "A Balanced Day"
                stressText = "Your stress levels were moderate, with a few periods of increased activity."
                color = .yellow
            case 50..<75:
                title = "A Demanding Day"
                stressText = "Your stress levels were high today, especially during certain parts of the day."
                color = .orange
            default:
                title = "A Stressful Day"
                stressText = "Your stress levels were very high today, indicating prolonged strain."
                color = .red
            }
        } else {
            title = "Daily Summary"
            stressText = "Stress data was limited today."
            color = .secondary
        }

        let sleepText: String = {
            guard let sleepScore else {
                return "Sleep data was not fully available."
            }

            switch sleepScore {
            case 85...:
                return "You had a restorative night of sleep, which supports recovery."
            case 70..<85:
                return "You had a decent night of sleep, providing some recovery."
            case 50..<70:
                return "Your sleep was limited, which may have reduced recovery."
            default:
                return "Your sleep quality was poor, which can affect stress and energy levels."
            }
        }()

       

        let body = """
        \(stressText) \(sleepText)

        """

        return DailyStressSummary(
            title: title,
            body: body,
            accentColor: color
        )
    }
}
