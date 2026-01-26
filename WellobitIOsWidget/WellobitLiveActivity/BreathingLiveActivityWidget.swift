//
//  BreathingLiveActivityWidget.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 06/01/26.

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct BreathingLiveActivityWidget: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BreathingLiveActivityAttributes.self) { context in
            let now = Date()
            let total = context.state.sessionEnd.timeIntervalSince(context.state.sessionStart)
            let elapsed = now.timeIntervalSince(context.state.sessionStart)
//            let progress = max(0, min(elapsed / total, 1))
            let displayEnd =
                context.state.sessionEnd
                    .addingTimeInterval(3)


            
//            HStack(spacing: 10) {



//                ProgressView(value: progress)
//                    .progressViewStyle(.circular)

            HStack() {
                Text("Let's finish the session.")
                    .font(.body)
                    .fontWeight(.regular)
//                            .monospacedDigit()
                    .foregroundStyle(.primary)
                
                Image("zenny")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }
            .padding()

        } dynamicIsland: { context in

            let now = Date()
            let total = context.state.sessionEnd.timeIntervalSince(context.state.sessionStart)
            let elapsed = now.timeIntervalSince(context.state.sessionStart)
            let progress = max(0, min(elapsed / total, 1))
            let displayEnd =
                context.state.sessionEnd
                    .addingTimeInterval(3)

            return DynamicIsland {

                // MARK: - Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    ZStack() {
//                        Text(displayEnd, style: .timer)
                        Text("Let's finish the session.")
                            .font(.body)
                            .fontWeight(.regular)
//                            .monospacedDigit()
                            .foregroundStyle(.primary)
                            .padding(.top)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                        Image("zenny")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                }
            }
            compactLeading: {
                Image("zenny")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
//                Text(displayEnd, style: .timer)
//                    .font(.footnote)
//                    .fontWeight(.bold)
//                    .monospacedDigit()
//                    .foregroundStyle(.primary)


            }
            compactTrailing: {
//                Text(displayEnd, style: .timer)
//                    .font(.footnote)
//                    .fontWeight(.bold)
//                    .monospacedDigit()
//                    .foregroundStyle(.primary)
            }
            minimal: {
//                Text(displayEnd, style: .timer)
//                    .font(.footnote)
//                    .fontWeight(.bold)
//                    .monospacedDigit()
//                    .foregroundStyle(.primary)

                Image("zenny")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
        }
    }
}
