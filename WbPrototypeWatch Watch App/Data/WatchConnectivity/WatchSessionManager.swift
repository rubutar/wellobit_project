//
//  WatchSessionManager.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 04/12/25.
//

import Foundation
import WatchConnectivity

final class WatchSessionManager: NSObject, WCSessionDelegate {

    static let shared = WatchSessionManager()

    // 🔗 Bridge target (UI state owner)
    private weak var workoutViewModel: WatchWorkoutViewModel?

    private override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - Binding

    /// Bind once from App / ExtensionDelegate
    func bind(to viewModel: WatchWorkoutViewModel) {
        self.workoutViewModel = viewModel
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        print(
            "⌚️ WCSession activated:",
            activationState.rawValue,
            "error:",
            String(describing: error)
        )
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any]
    ) {
        print("⌚️ Received message:", message)

        // 1️⃣ HRV update (existing behavior)
        if let hrv = message["hrv"] as? Int {
            DispatchQueue.main.async {
                self.workoutViewModel?.currentHRV = hrv
            }
            return
        }

        // 2️⃣ Breathing pre-session message
        guard message["type"] as? String == "breathing_pre_session" else {
            return
        }

        let cycles = message["cycles"] as? Int ?? 0
        let totalSeconds = message["totalSeconds"] as? Int ?? 0

        DispatchQueue.main.async {
            self.workoutViewModel?.handlePreSession(
                cycles: cycles,
                totalSeconds: totalSeconds
            )
        }
    }
}
