//
//  WatchSessionManager.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 09/01/26.
//


import Foundation
import WatchConnectivity

final class WatchSessionManager: NSObject, WCSessionDelegate {

    static let shared = WatchSessionManager()

    private override init() {
        super.init()
        activate()
    }

    private func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    // MARK: - Send message
    func sendPreSession(
        cycles: Int,
        totalSeconds: Int
    ) {
        guard WCSession.default.isReachable else {
            print("⌚️ Watch not reachable")
            return
        }

        let message: [String: Any] = [
            "type": "breathing_pre_session",
            "cycles": cycles,
            "totalSeconds": totalSeconds
        ]

        WCSession.default.sendMessage(
            message,
            replyHandler: nil,
            errorHandler: { error in
                print("⌚️ Failed to send message:", error.localizedDescription)
            }
        )
    }

    // MARK: - WCSessionDelegate (required)
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) { }

    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}
