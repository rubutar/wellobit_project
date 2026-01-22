//
//  BreathingLiveActivityController.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 06/01/26.
//

//import ActivityKit
//import Foundation
//
//final class BreathingLiveActivityController {
//
//    private var activity: Activity<BreathingLiveActivityAttributes>?
//
//    // MARK: - Start
////    func start(
////        totalCycles: Int,
////        phase: String,
////        remainingSeconds: Int,
////        phaseTotalSeconds: Int
////    ) {
////        guard activity == nil else { return }
////
////        let attributes = BreathingLiveActivityAttributes(
////            totalCycles: totalCycles
////        )
////
////        let contentState = BreathingLiveActivityAttributes.ContentState(
////            phase: phase,
////            remainingSeconds: remainingSeconds,
////            phaseTotalSeconds: phaseTotalSeconds
////        )
////
////        do {
////            activity = try Activity.request(
////                attributes: attributes,
////                contentState: contentState,
////                pushType: nil
////            )
////        } catch {
////            print("❌ Failed to start live activity:", error)
////        }
////    }
//    
//    func start(
//        totalCycles: Int,
//        phase: String,
//        phaseStart: Date,
//        phaseEnd: Date
//    ) {
//        guard activity == nil else { return }
//
//        let attributes = BreathingLiveActivityAttributes(
//            totalCycles: totalCycles
//        )
//
//        let contentState = BreathingLiveActivityAttributes.ContentState(
//            phase: phase,
//            phaseStart: phaseStart,
//            phaseEnd: phaseEnd
//        )
//
//        do {
//            activity = try Activity.request(
//                attributes: attributes,
//                contentState: contentState,
//                pushType: nil
//            )
//        } catch {
//            print("❌ Failed to start live activity:", error)
//        }
//    }
//
//
//    // MARK: - Update
////    func update(
////        phase: String,
////        remainingSeconds: Int,
////        phaseTotalSeconds: Int
////    ) {
////        guard let activity else { return }
////
////        let newState = BreathingLiveActivityAttributes.ContentState(
////            phase: phase,
////            remainingSeconds: remainingSeconds,
////            phaseTotalSeconds: phaseTotalSeconds
////        )
////
////        Task {
////            await activity.update(using: newState)
////        }
////    }
//    func update(
//        phase: String,
//        phaseStart: Date,
//        phaseEnd: Date
//    ) {
//        guard let activity else { return }
//
//        let newState = BreathingLiveActivityAttributes.ContentState(
//            phase: phase,
//            phaseStart: phaseStart,
//            phaseEnd: phaseEnd
//        )
//
//        Task {
//            await activity.update(using: newState)
//        }
//    }
//
//    // MARK: - End
//    func end() {
//        guard let activity else { return }
//
//        Task {
//            await activity.end(dismissalPolicy: .immediate)
//            self.activity = nil
//        }
//    }
//}


import ActivityKit
import Foundation

final class BreathingLiveActivityController {

    private var activity: Activity<BreathingLiveActivityAttributes>?

    func start(
        totalCycles: Int,
        sessionStart: Date,
        sessionEnd: Date
    ) {
        guard activity == nil else { return }

        let attributes = BreathingLiveActivityAttributes(
            totalCycles: totalCycles
        )

        let contentState = BreathingLiveActivityAttributes.ContentState(
            sessionStart: sessionStart,
            sessionEnd: sessionEnd
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
        } catch {
            print("❌ Failed to start Live Activity:", error)
        }
    }

    func end() {
        guard let activity else { return }

        Task {
            await activity.end(dismissalPolicy: .immediate)
            self.activity = nil
        }
    }
}
