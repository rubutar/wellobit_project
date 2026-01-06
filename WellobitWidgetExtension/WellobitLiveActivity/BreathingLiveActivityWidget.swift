//
//  BreathingLiveActivityWidget.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 06/01/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Widget

struct BreathingLiveActivityWidget: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BreathingLiveActivityAttributes.self) { context in
            let icon = phaseIcon(for: context.state.phase)

            HStack {
                Image(systemName: icon.name)
                    .font(.title2)
                    .rotationEffect(.degrees(icon.rotation))

                VStack(alignment: .leading) {
                    Text(context.state.phase.capitalized)
                        .font(.headline)
                    Text("Remaining: \(context.state.remainingSeconds)s")
                        .font(.caption)
                }

                Spacer()
            }
            .padding()

        } dynamicIsland: { context in

            DynamicIsland {

                // LEFT
                DynamicIslandExpandedRegion(.leading) {
                    let icon = phaseIcon(for: context.state.phase)

                    Image(systemName: icon.name)
                        .font(.title2)
                        .rotationEffect(.degrees(icon.rotation))
                }

                // CENTER
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.phase.uppercased())
                        .font(.caption)
                }

                // RIGHT
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.remainingSeconds)s")
                        .font(.headline)
                }

            } compactLeading: {
                let icon = phaseIcon(for: context.state.phase)

                Image(systemName: icon.name)
                    .rotationEffect(.degrees(icon.rotation))

            } compactTrailing: {
                let total = Double(context.state.phaseTotalSeconds)
                let remaining = min(Double(context.state.remainingSeconds), total)
                let progress = 1 - (remaining / total)
                let lineWidth: CGFloat = 3

                ZStack {
                    // Background ring
                    Circle()
                        .inset(by: lineWidth / 2)
                        .stroke(lineWidth: lineWidth)
                        .opacity(0.25)

                    // Progress ring
                    Circle()
                        .inset(by: lineWidth / 2)
                        .trim(from: 0, to: progress)
                        .stroke(
                            style: StrokeStyle(
                                lineWidth: lineWidth,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))

                    // Seconds text
                    Text("\(context.state.remainingSeconds)")
                        .font(.system(size: 9, weight: .semibold))
                        .monospacedDigit()
                }
                .frame(width: 20, height: 20)

            } minimal: {
                let icon = phaseIcon(for: context.state.phase)

                Image(systemName: icon.name)
                    .rotationEffect(.degrees(icon.rotation))
            }
        }
    }

    // MARK: - Phase Icon Mapping

    private func phaseIcon(for phase: String) -> (name: String, rotation: Double) {
        switch phase.lowercased() {
        case "inhale":
            return ("wind", 180)
        case "exhale":
            return ("wind", 0)
        default:
            return ("circle.circle", 0)
        }
    }
}
