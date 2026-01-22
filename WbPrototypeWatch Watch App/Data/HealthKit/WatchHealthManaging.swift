
//
//  WatchHealthManager.swift
//  WellobitWatch Watch App
//
//  Created by Rudi Butarbutar on 27/12/25.
//

import Foundation
import HealthKit
import Combine

protocol WatchHealthManaging {
    func requestAuthorization()
    func startWorkoutSession(with configuration: HKWorkoutConfiguration)
    func stopWorkoutSession()
}

//final class WatchHealthManager: NSObject,
//    WatchHealthManaging,
//    HKWorkoutSessionDelegate,
//    HKLiveWorkoutBuilderDelegate
//{
//    
//    private let healthStore = HKHealthStore()
//    private var workoutSession: HKWorkoutSession?
//    private var workoutBuilder: HKLiveWorkoutBuilder?
//    
//    // RR Interval Storage
//    private var rrAnchor: HKQueryAnchor?
//    private var lastBeatDate: Date?
//    @Published var rrIntervalsMs: [Double] = []

final class WatchHealthManager: NSObject,
    WatchHealthManaging,
    HKWorkoutSessionDelegate,
    HKLiveWorkoutBuilderDelegate
{
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    
    // 🔥 Heartbeat series (needed to SAVE beat-to-beat data)
    private var heartbeatSeriesStartDate: Date?
    private var heartbeatBuilder: HKHeartbeatSeriesBuilder?
    
    // RR Interval Storage
    private var rrAnchor: HKQueryAnchor?
    private var lastBeatDate: Date?
    @Published var rrIntervalsMs: [Double] = []
    
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available on this device.")
            return
        }
        
        let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        
        // We want to WRITE workouts
        let typesToShare: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            mindfulType
        ]
        
        // And READ heart rate + HRV
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKSeriesType.heartbeat()
        ]
        
        Task {
            do {
                try await healthStore.requestAuthorization(
                    toShare: typesToShare,
                    read: typesToRead
                )
                print("HK authorization success (read+write workout)")
            } catch {
                print("HK authorization failed: \(error)")
            }
        }
    }
    
    
    // MARK: - Start Workout
    
//    func startWorkoutSession(with configuration: HKWorkoutConfiguration) {
//        guard workoutSession == nil else {
//            print("Workout already running")
//            return
//        }
//        
//        do {
//            let session = try HKWorkoutSession(
//                healthStore: healthStore,
//                configuration: configuration
//            )
//            
//            let builder = session.associatedWorkoutBuilder()
//            
//            // Live data source (HR, energy, etc.)
//            builder.dataSource = HKLiveWorkoutDataSource(
//                healthStore: healthStore,
//                workoutConfiguration: configuration
//            )
//            
//            session.delegate = self
//            builder.delegate = self
//            
//            let startDate = Date()
//            
//            workoutSession = session
//            workoutBuilder = builder
//            
//            session.startActivity(with: startDate)
//            builder.beginCollection(withStart: startDate) { success, error in
//                if let error = error {
//                    print("Begin collection error: \(error)")
//                } else {
//                    print("Workout collection started")
//                }
//            }
//            startRRObservation(from: startDate)
//            print("Workout session started.")
//            
//        } catch {
//            print("Failed to start workout session: \(error)")
//        }
//    }
    
    func startWorkoutSession(with configuration: HKWorkoutConfiguration) {
        guard workoutSession == nil else {
            print("Workout already running")
            return
        }
        
        do {
            // MARK: Create Workout Session
            let session = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            
            let builder = session.associatedWorkoutBuilder()
            
            // Live data source (HR, active energy, etc.)
            builder.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            
            session.delegate = self
            builder.delegate = self
            
            let startDate = Date()
            
            // Save references
            workoutSession = session
            workoutBuilder = builder
            
            // MARK: Start Workout
            session.startActivity(with: startDate)
            builder.beginCollection(withStart: startDate) { success, error in
                if let error = error {
                    print("Begin collection error: \(error)")
                } else {
                    print("🏃‍♂️ Workout collection started")
                }
            }
            
            // MARK: Start Heartbeat Series Builder
            heartbeatSeriesStartDate = startDate
            heartbeatBuilder = HKHeartbeatSeriesBuilder(
                healthStore: healthStore,
                device: HKDevice.local(),
                start: startDate
            )
            
            print("🔥 Heartbeat Series Builder started at:", startDate)
            
            // MARK: Begin RR (beat-to-beat) Observation
            startRRObservation(from: startDate)
            
            print("Workout session started.")
            
        } catch {
            print("Failed to start workout session: \(error)")
        }
    }

    
    
    // MARK: - Stop Workout
    
    func stopWorkoutSession() {
        guard let session = workoutSession,
              let builder = workoutBuilder else {
            print("No active workout to stop")
            return
        }
        
        let endDate = Date()
        
        session.stopActivity(with: endDate)
        stopRRObservation()
        builder.endCollection(withEnd: endDate) { [weak self] success, error in
            if let error = error {
                print("End collection error: \(error)")
            }
            
//            builder.finishWorkout { workout, error in
//                if let error = error {
//                    print("Finish workout error: \(error)")
//                } else {
//                    print("Workout finished: \(String(describing: workout))")
//                }
//                
//                DispatchQueue.main.async {
//                    self?.workoutSession = nil
//                    self?.workoutBuilder = nil
//                }
//            }
            
            builder.finishWorkout { workout, error in
                if let error = error {
                    print("Finish workout error: \(error)")
                } else if let workout = workout {
                    print("Workout finished: \(String(describing: workout))")
                    
                    if let strongSelf = self {
                        print("Total RR intervals collected: \(strongSelf.rrIntervalsMs.count)")
                        print("RR intervals (ms): \(strongSelf.rrIntervalsMs)")
                        strongSelf.debugCheckHeartbeatSeries(after: workout)
                        strongSelf.saveMindfulSession(from: workout.startDate, to: workout.endDate)
                        strongSelf.fetchHRVForSession(start: workout.startDate, end: workout.endDate)

                    }
                    
                }
                
                DispatchQueue.main.async {
                    self?.workoutSession = nil
                    self?.workoutBuilder = nil
                }
            }
        }
        
        print("Workout session stopping...")
    }
    
    
    // MARK: - HKWorkoutSessionDelegate
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        print("Workout state changed: \(fromState.rawValue) -> \(toState.rawValue)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didFailWithError error: Error) {
        print("Workout session failed: \(error)")
    }
    
    
    // MARK: - HKLiveWorkoutBuilderDelegate
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                        didCollectDataOf collectedTypes: Set<HKSampleType>) {
        print("Workout builder collected data: \(collectedTypes)")
        // later: read HR here
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        print("Workout builder collected an event.")
    }
    
    private func startRRObservation(from startDate: Date) {
        let heartbeatType = HKSeriesType.heartbeat()
        
        rrAnchor = nil
        lastBeatDate = nil
        rrIntervalsMs = []
        
        // 1. Initial anchor query
        let anchoredQuery = HKAnchoredObjectQuery(
            type: heartbeatType,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: nil, options: []),
            anchor: rrAnchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, newAnchor, error in
            if let error = error {
                print("RR initial query error: \(error)")
                return
            }
            
            self?.rrAnchor = newAnchor
            self?.processHeartbeatSamples(samples)
        }
        
        // 2. Observer query to detect new heartbeats
        let observerQuery = HKObserverQuery(
            sampleType: heartbeatType,
            predicate: HKQuery.predicateForSamples(withStart: startDate, end: nil, options: [])
        ) { [weak self] _, completionHandler, error in
            
            if let error = error {
                print("RR observer error: \(error)")
                completionHandler()
                return
            }
            
            guard let self = self else {
                completionHandler()
                return
            }
            
            let updateQuery = HKAnchoredObjectQuery(
                type: heartbeatType,
                predicate: HKQuery.predicateForSamples(withStart: startDate, end: nil, options: []),
                anchor: self.rrAnchor,
                limit: HKObjectQueryNoLimit
            ) { _, samples, _, newAnchor, error in
                
                if let error = error {
                    print("RR update query error: \(error)")
                } else {
                    self.rrAnchor = newAnchor
                    self.processHeartbeatSamples(samples)
                }
                completionHandler()
            }
            
            self.healthStore.execute(updateQuery)
        }
        
        healthStore.execute(anchoredQuery)
        healthStore.execute(observerQuery)
        
        print("RR observation started.")
    }

    private func stopRRObservation() {
        // Stopping observer queries is optional because workout end stops them naturally
        print("RR observation stopped.")
    }

    private func processHeartbeatSamples(_ samples: [HKSample]?) {
        guard let seriesSamples = samples as? [HKHeartbeatSeriesSample] else { return }
        
        for sample in seriesSamples {
            readHeartbeatSeries(sample)
        }
    }

//    private func readHeartbeatSeries(_ seriesSample: HKHeartbeatSeriesSample) {
//        let query = HKHeartbeatSeriesQuery(heartbeatSeries: seriesSample) {
//            [weak self] _, timeSinceStart, precededByGap, done, error in
//            
//            if let error = error {
//                print("Heartbeat series query error: \(error)")
//                return
//            }
//            
//            guard let self = self else { return }
//            
//            // Convert to actual timestamp
//            let beatDate = seriesSample.startDate.addingTimeInterval(timeSinceStart)
//            
//            if let previous = self.lastBeatDate {
//                let rrSeconds = beatDate.timeIntervalSince(previous)
//                let rrMs = rrSeconds * 1000.0
//                
//                if rrMs > 0, rrMs < 3000 { // sanity filter
//                    DispatchQueue.main.async {
//                        self.rrIntervalsMs.append(rrMs)
//                    }
//                }
//            }
//            
//            self.lastBeatDate = beatDate
//            
//            // if done == true → end of series
//        }
//        
//        healthStore.execute(query)
//    }
//    private func readHeartbeatSeries(_ seriesSample: HKHeartbeatSeriesSample) {
//        let query = HKHeartbeatSeriesQuery(heartbeatSeries: seriesSample) {
//            [weak self] _, timeSinceStart, precededByGap, done, error in
//            
//            if let error = error {
//                print("Heartbeat series query error: \(error)")
//                return
//            }
//            
//            guard let self = self else { return }
//            
//            let beatDate = seriesSample.startDate.addingTimeInterval(timeSinceStart)
//            print("Beat at: \(beatDate) (gap: \(precededByGap))")
//            
//            if let previous = self.lastBeatDate {
//                let rrSeconds = beatDate.timeIntervalSince(previous)
//                let rrMs = rrSeconds * 1000.0
//                
//                if rrMs > 0, rrMs < 3000 {
//                    DispatchQueue.main.async {
//                        self.rrIntervalsMs.append(rrMs)
//                        print("RR interval: \(rrMs) ms")
//                    }
//                }
//            }
//            
//            self.lastBeatDate = beatDate
//        }
//        
//        healthStore.execute(query)
//    }
    
    private func readHeartbeatSeries(_ seriesSample: HKHeartbeatSeriesSample) {
        let query = HKHeartbeatSeriesQuery(heartbeatSeries: seriesSample) {
            [weak self] _, timeSinceStart, precededByGap, done, error in
            
            if let error = error {
                print("Heartbeat series query error: \(error)")
                return
            }
            
            guard let self = self else { return }
            
            let beatDate = seriesSample.startDate.addingTimeInterval(timeSinceStart)
            print("❤️ Beat at:", beatDate, "gap:", precededByGap)
            
            // 1️⃣ SAVE beat to heartbeat series (THIS WAS MISSING)
            if let hbBuilder = self.heartbeatBuilder,
               let seriesStart = self.heartbeatSeriesStartDate {

                let offset = beatDate.timeIntervalSince(seriesStart)

                Task {
                    do {
                        try await hbBuilder.addHeartbeat(
                            at: offset,
                            precededByGap: precededByGap
                        )
                        print("💾 Saved beat offset:", offset)
                    } catch {
                        print("❌ Heartbeat save error:", error)
                    }
                }
            }

            // 2️⃣ Compute RR interval
            if let previous = self.lastBeatDate {
                let rrMs = beatDate.timeIntervalSince(previous) * 1000
                if rrMs > 250 && rrMs < 2000 {
                    DispatchQueue.main.async {
                        print("⏱ RR:", rrMs, "ms")
                        self.rrIntervalsMs.append(rrMs)
                    }
                }
            }
            
            // 3️⃣ Update last beat
            self.lastBeatDate = beatDate
        }
        
        healthStore.execute(query)
    }

    
    
    private func debugCheckHeartbeatSeries(after workout: HKWorkout) {
        let heartbeatType = HKSeriesType.heartbeat()
        
        let predicate = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: []
        )
        
        let query = HKSampleQuery(
            sampleType: heartbeatType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, error in
            if let error = error {
                print("Debug heartbeat series query error: \(error)")
                return
            }
            
            let count = samples?.count ?? 0
            print("Heartbeat series samples stored in HK during this workout: \(count)")
        }
        
        healthStore.execute(query)
    }
    
    func fetchHRVForSession(start: Date, end: Date) {
        let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: hrvType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, _ in
            guard let samples = results as? [HKQuantitySample] else { return }
            
            for sample in samples {
                let hrvValue = sample.quantity.doubleValue(for: .secondUnit(with: .milli))
                print("HRV (SDNN) during session: \(hrvValue) ms")
            }
        }
        healthStore.execute(query)
    }
    
    
    private func saveMindfulSession(from start: Date, to end: Date) {
        guard let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else {
            print("Mindful session type unavailable")
            return
        }
        
        let mindfulSample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end
        )
        
        healthStore.save(mindfulSample) { success, error in
            if let error = error {
                print("Failed to save mindful session: \(error)")
            } else {
                print("Mindful session saved to Health: \(success)")
            }
        }
    }

}
