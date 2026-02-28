//
//  LocalStretchRepository.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 27/02/26.
//


import Foundation

final class LocalStretchRepository: StretchRepository {
    
    func fetchRoutines() async throws -> [StretchRoutine] {
        
        let stepLibrary = try loadSteps()
        let routineDTOs = try loadRoutineDTOs()
        
        let resolvedRoutines = routineDTOs.map { dto in
            
            let resolvedSteps = dto.steps.compactMap { ref -> StretchStep? in
                
                guard let stepData = stepLibrary.first(where: { $0.id == ref.stepId }) else {
                    print("⚠️ Missing step for id:", ref.stepId)
                    return nil
                }
                
                return StretchStep(
                    id: stepData.id,
                    name: stepData.name,
                    imageName: stepData.imageName,
                    instructions: stepData.instructions,
                    tips: stepData.tips,
                    modifications: stepData.modifications,
                    benefits: stepData.benefits,
                    caution: stepData.caution,
                    defaultDuration: ref.defaultDuration
                )
            }
            
            return StretchRoutine(
                id: dto.id,
                title: dto.title,
                description: dto.description,
                category: dto.category,
                steps: resolvedSteps
            )
        }
        
        return resolvedRoutines
    }
    
    // MARK: - Private
    
    private func loadSteps() throws -> [StretchStepLibrary] {
        guard let url = Bundle.main.url(forResource: "stretch_steps", withExtension: "json") else {
            throw URLError(.fileDoesNotExist)
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([StretchStepLibrary].self, from: data)
    }
    
    private func loadRoutineDTOs() throws -> [StretchRoutineDTO] {
        guard let url = Bundle.main.url(forResource: "stretch_routines", withExtension: "json") else {
            throw URLError(.fileDoesNotExist)
        }
        
        let data = try Data(contentsOf: url)

        return try JSONDecoder().decode([StretchRoutineDTO].self, from: data)
    }
    
}
