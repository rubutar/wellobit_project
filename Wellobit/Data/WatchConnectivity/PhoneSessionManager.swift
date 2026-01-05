//
//  PhoneSessionManager.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 04/12/25.
//


// PhoneSessionManager.swift
import Foundation
import WatchConnectivity
import Combine

final class PhoneSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = PhoneSessionManager()

    @Published var lastSentHRV: Int? = nil

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendDummyHRV() {
        let dummyHRV = Int.random(in: 30...110)
        lastSentHRV = dummyHRV

        let message: [String: Any] = [
            "hrv": dummyHRV
        ]

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Error sending HRV: \(error.localizedDescription)")
            })
        } else {
            print("Watch is not reachable")
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("iPhone WCSession activation: \(activationState.rawValue), error: \(String(describing: error))")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
