//
//  FetchSleepStagesUseCase.swift
//  Wellobit
//
//  Created by Rudi Butarbutar on 10/01/26.
//


protocol FetchSleepStagesUseCase {
    func execute() async throws -> [SleepStage]
}
