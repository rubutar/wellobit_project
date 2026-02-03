//
//  LibraryListViewModel.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 01/02/26.
//


// Presentation/Library/LibraryListViewModel.swift

import Foundation
import Combine

//final class LibraryListViewModel: ObservableObject {
//
//    @Published private(set) var sessionsByCategory: [BreathingCategory: [BreathingSession]] = [:]
//
//    private let getSessionsUseCase: GetLibraryBreathingSessionsUseCase
//
//    init(getSessionsUseCase: GetLibraryBreathingSessionsUseCase) {
//        self.getSessionsUseCase = getSessionsUseCase
//        load()
//    }
//
//    private func load() {
//        let sessions = getSessionsUseCase.execute()
//        sessionsByCategory = Dictionary(grouping: sessions, by: { $0.category })
//    }
//}


final class LibraryListViewModel: ObservableObject {

    @Published var sessionsByCategory: [BreathingCategory: [BreathingSession]] = [:]
    @Published var selectedSession: BreathingSession?
    @Published var showPlayer = false

    private let getSessionsUseCase: GetLibraryBreathingSessionsUseCase
    private let breathingRepository: BreathingRepository

    init(
        getSessionsUseCase: GetLibraryBreathingSessionsUseCase,
        breathingRepository: BreathingRepository
    ) {
        self.getSessionsUseCase = getSessionsUseCase
        self.breathingRepository = breathingRepository
        load()   // 👈 don’t forget this
    }

    private func load() {
        let sessions = getSessionsUseCase.execute()
        sessionsByCategory = Dictionary(grouping: sessions, by: { $0.category })
    }

    func select(_ session: BreathingSession) {
        guard let settings = session.preset.settings else {
            return // custom → handle later
        }

        breathingRepository.save(settings: settings)
        selectedSession = session
    }
    func startSession(_ session: BreathingSession) {
        print("🟢 startSession called for:", session.title)

        if let settings = session.preset.settings {
            breathingRepository.save(settings: settings)
        }

        showPlayer = true
        print("🟢 showPlayer =", showPlayer)
    }
}
