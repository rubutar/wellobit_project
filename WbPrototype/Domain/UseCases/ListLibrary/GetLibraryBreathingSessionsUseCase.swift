//
//  GetLibraryBreathingSessionsUseCase.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 01/02/26.
//



struct GetLibraryBreathingSessionsUseCase {
    private let repository: LibraryBreathingRepository

    init(repository: LibraryBreathingRepository) {
        self.repository = repository
    }

    func execute() -> [BreathingSession] {
        repository.fetchLibrarySessions()
    }
}
