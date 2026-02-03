//
//  LoadBreathingProgressUseCase.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 02/02/26.
//


final class LoadBreathingProgressUseCase {

    private let repository: BreathingProgressRepository

    init(repository: BreathingProgressRepository) {
        self.repository = repository
    }

    func execute() -> BreathingProgress {
        repository.load()
    }
}
