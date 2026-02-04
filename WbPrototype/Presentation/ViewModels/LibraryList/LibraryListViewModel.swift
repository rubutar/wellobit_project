//
//  LibraryListViewModel.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 01/02/26.
//



import Foundation
import Combine
import SwiftUI
//
//final class LibraryListViewModel: ObservableObject {
//
//    @Published var sessionsByCategory: [BreathingCategory: [BreathingSession]] = [:]
//    @Published var showDetail = false
//    @Published var selectedSession: BreathingSession?
//    @Published var showPlayer = false
//
//    private let getSessionsUseCase: GetLibraryBreathingSessionsUseCase
//    private let breathingRepository: BreathingRepository
//
//    init(
//        getSessionsUseCase: GetLibraryBreathingSessionsUseCase,
//        breathingRepository: BreathingRepository
//    ) {
//        self.getSessionsUseCase = getSessionsUseCase
//        self.breathingRepository = breathingRepository
//        load()   // 👈 don’t forget this
//    }
//
//    private func load() {
//        let sessions = getSessionsUseCase.execute()
//        sessionsByCategory = Dictionary(grouping: sessions, by: { $0.category })
//    }
//
//    func select(_ session: BreathingSession) {
//        guard let settings = session.preset.settings else {
//            return // custom → handle later
//        }
//
//        breathingRepository.save(settings: settings)
//        selectedSession = session
//    }
//    func startSession(_ session: BreathingSession) {
//        print("🟢 startSession called for:", session.title)
//
//        if let settings = session.preset.settings {
//            breathingRepository.save(settings: settings)
//        }
//
//        showPlayer = true
//        print("🟢 showPlayer =", showPlayer)
//    }
//}

//final class LibraryListViewModel: ObservableObject {
//
//    @Published var sessionsByCategory: [BreathingCategory: [BreathingSession]] = [:]
//
//    // Navigation state
//    @Published var selectedSession: BreathingSession?
//    @Published var showDetail = false       // iOS 16
//    @Published var showPlayer = false       // both
//
//    private let getSessionsUseCase: GetLibraryBreathingSessionsUseCase
//    private let breathingRepository: BreathingRepository
//
//    init(
//        getSessionsUseCase: GetLibraryBreathingSessionsUseCase,
//        breathingRepository: BreathingRepository
//    ) {
//        self.getSessionsUseCase = getSessionsUseCase
//        self.breathingRepository = breathingRepository
//        load()
//    }
//
//    private func load() {
//        let sessions = getSessionsUseCase.execute()
//        sessionsByCategory = Dictionary(grouping: sessions, by: { $0.category })
//    }
//
//    func select(_ session: BreathingSession) {
//        selectedSession = session
//        showDetail = true   // only used on iOS 16
//    }
//
//    func startSession(_ session: BreathingSession) {
//        if let settings = session.preset.settings {
//            breathingRepository.save(settings: settings)
//        }
//
//        showPlayer = true
//    }
//}

enum LibraryRoute: Hashable {
    case detail(BreathingSession)
    case player
}

final class LibraryListViewModel: ObservableObject {

    @Published var sessionsByCategory: [BreathingCategory: [BreathingSession]] = [:]
    @Published var path = NavigationPath()
    
    @Published var activeSession: BreathingSession?

    private let getSessionsUseCase: GetLibraryBreathingSessionsUseCase
    private let breathingRepository: BreathingRepository

    init(
        getSessionsUseCase: GetLibraryBreathingSessionsUseCase,
        breathingRepository: BreathingRepository
    ) {
        self.getSessionsUseCase = getSessionsUseCase
        self.breathingRepository = breathingRepository
        load()
    }

    private func load() {
        let sessions = getSessionsUseCase.execute()
        sessionsByCategory = Dictionary(grouping: sessions, by: { $0.category })
    }

    // Library → Detail
    func select(_ session: BreathingSession) {
        path.append(LibraryRoute.detail(session))
    }
    

    // Detail → Player
    func startSession(_ session: BreathingSession) {
        if let settings = session.preset.settings {
            breathingRepository.save(settings: settings)
        }
        path.append(LibraryRoute.player)
    }
}

