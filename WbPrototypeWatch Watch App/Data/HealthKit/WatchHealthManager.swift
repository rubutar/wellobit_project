////
////  WatchHealthManager.swift
////  Wellobit
////
////  Created by Rudi Butarbutar on 27/12/25.
////
//
//import Foundation
//import HealthKit
//
//protocol WatchHealthManaging {
//    func requestAuthorization()
//    func startWorkoutSession(with configuration: HKWorkoutConfiguration)
//    func stopWorkoutSession()
//}
//
//final class WatchHealthManager: NSObject, WatchHealthManaging {
//    private let healthStore = HKHealthStore()
//    private var workoutSession: HKWorkoutSession?
//    private var workoutBuilder: HKLiveWorkoutBuilder?
//    
//    func requestAuthorization() {
//        guard HKHealthStore.isHealthDataAvailable() else {
//            print("Health data not available on this device")
//            return
//        }
//        
//        var typesToShare: Set<HKSampleType> = [
//            HKObjectType.workoutType()
//        ]
//
//        var typesToRead: Set<HKObjectType> = [
//            HKObjectType.quantityType(forIdentifier: .heartRate)!,
//            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
//        ]
//        // (Optional) later we can add RR / heartbeat series here:
//        // let heartbeatType = HKSeriesType.heartbeat()
//        // typesToRead.insert(heartbeatType)
//        
//        // Request Authorization
//        Task {
//            do {
//                try await healthStore.requestAuthorization(
//                    toShare: typesToShare,
//                    read: typesToRead
//                )
//                print("HK authorization success (read+write)")
//            } catch {
//                print("HK authorization failed: \(error)")
//            }
//        }
//    }
//    
//    func startWorkoutSession(with configuration: HKWorkoutConfiguration) {
//        guard workoutSession == nil else {
//            print("Workout already running")
//            return
//        }
//        do {
//            let session = try HKWorkoutSession(
//                healthStore: healthStore,
//                configuration: configuration
//            )
//            
//            let builder = session.associatedWorkoutBuilder()
//            
////            Live data source
//            builder.dataSource = HKLiveWorkoutDataSource(
//                healthStore: healthStore,
//                workoutConfiguration: configuration
//            )
//            
//            session.delegate = self
//            builder.delegate = self
//            
//            let startdate = Date()
//            
//            workoutSession = session
//            workoutBuilder = builder
//            
//            session.startActivity(with: startdate)
//            builder.beginCollection(withStart: startdate) { success, error in
//                if let error = error {
//                    print("Begin collection error:\(error)")
//                } else {
//                    print("Workout collection started")
//                }
//            }
//            print("Workout session started.")
//            
//        } catch {
//            print("Failed to start workout session \(error)")
//        }
//    }
//    
//    func stopWorkoutSession() {
//        print("watchHealthManager: stopWorkoutSession()")
//    }
//}
//
//
//extension WatchHealthManager: HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
//    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
//        print("Workout state changed: \(fromState.rawValue) -> \(toState.rawValue)")
//    }
//    
//    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
//        print("Workout session failed: \(error)")
//    }
//    
//    func workoutBuilderDidCollectData(_ workoutBuilder: HKLiveWorkoutBuilder) {
//        // later we can read heart rate here
//        // for now we just log
//        print("Workout builder collected data.")
//    }
//    
//    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
//                        didCollectEvents events: [HKWorkoutEvent]) {
//        // Not used yet
//        print("Builder collected events: \(events.count)")
//
//    }
//}
