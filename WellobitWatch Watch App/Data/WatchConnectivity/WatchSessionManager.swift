//
//  WatchSessionManager.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 04/12/25.
//


// WatchSessionManager.swift (watchOS)
import Foundation
import WatchConnectivity
import Combine

final class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSessionManager()

    @Published var currentHRV: Int? = nil

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        print("Watch WCSession activation: \(activationState.rawValue), error: \(String(describing: error))")
    }

    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any]) {
        if let hrv = message["hrv"] as? Int {
            DispatchQueue.main.async {
                self.currentHRV = hrv
            }
        }
    }
}
