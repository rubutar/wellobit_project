//
//  BreathingLiveActivityController.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 06/01/26.
//

import ActivityKit

final class BreathingLiveActivityController {
    private var activity: Activity<BreathingLiveActivityAttributes>?
    
    func start(
        totalCycles: Int,
        phase: String,
        remainingSeconds: Int,
        phaseTotalSeconds: Int
    ) {
        guard activity == nil else { return }
        
        let attributes = BreathingLiveActivityAttributes(
            totalCycles: totalCycles
        )
        
        let contentState = BreathingLiveActivityAttributes.ContentState(
            phase: phase,
            remainingSeconds: remainingSeconds,
            phaseTotalSeconds: phaseTotalSeconds
        )
        
        do {
            activity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
        } catch {
            print("Failed to start live activity", error)
        }
    }
    
    func update(
        phase: String,
        remainingSeconds: Int,
        phaseTotalSeconds: Int
    ) {
        guard let activity else { return }
        
        let newState = BreathingLiveActivityAttributes.ContentState(
            phase: phase, remainingSeconds: remainingSeconds, phaseTotalSeconds: phaseTotalSeconds
        )
        
        Task {
            await activity.update(
                using: .init(
                    phase: "inhale",
                    remainingSeconds: remainingSeconds,
                    phaseTotalSeconds: phaseTotalSeconds
                )
            )        }
    }
    
    func end() {
        guard let activity else { return }
        
        Task {
            await activity.end(dismissalPolicy: .immediate)
            self.activity = nil
        }
    }
}
