//
//  StretchRoutineListViewModel.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/02/26.
//

import Foundation
import Combine


@MainActor
final class StretchRoutineListViewModel: ObservableObject {
    
    private let repository: StretchRepository
    
    @Published var routines: [StretchRoutine] = []
    
    init(repository: StretchRepository) {
        self.repository = repository
    }
    
    func loadRoutines() async {
        do {
            routines = try await repository.fetchRoutines()
        } catch {
            print("Failed to load routines: \(error)")
        }
    }
}
