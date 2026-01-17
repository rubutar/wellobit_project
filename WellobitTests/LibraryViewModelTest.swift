//
//  File.swift
//  WellobitTests
//
//  Created by Rudi Butarbutar on 15/01/26.
//

import XCTest
@testable import Wellobit

@MainActor
final class LibraryViewModelTest: XCTestCase {
    private var repository: MockBreathingRepository!
    private var viewModel: LibraryViewModel!
    
    override func setUp() {
        super.setUp()
        repository = MockBreathingRepository()
        viewModel = LibraryViewModel(
            repository: repository,
            initial: repository.load()
        )
    }
    
    override func tearDown() {
        repository = nil
        viewModel = nil
        super.tearDown()
    }
    
    func test_cycleCountUpdatesTotalDuration() {
        viewModel.cycleCount = 5
        let totalSeconds = viewModel.totalDurationSeconds
        XCTAssertGreaterThan(totalSeconds, 0)
    }
    
    func test_selectPhase_setsSelectedPhase() {
        // When
        viewModel.select(.inhale)

        // Then
        XCTAssertEqual(viewModel.selectedPhase, .inhale)
    }

    func test_closeSelection_clearsSelectedPhase() {
        // Given
        viewModel.select(.exhale)

        // When
        viewModel.closeSelection()

        // Then
        XCTAssertNil(viewModel.selectedPhase)
    }

    func test_updatePhaseValue_updatesSettings() {
        // When
        viewModel.update(phase: .inhale, value: 6)

        // Then
        XCTAssertEqual(viewModel.settings.inhale, 6)
    }

    func test_selectPreset_updatesSettings() {
        // When
        viewModel.selectedPreset = .fourSevenEight

        // Then
        XCTAssertNotEqual(viewModel.settings.inhale, 5)
    }

    func test_libraryView_initializes() {
        let repo = MockBreathingRepository()
        let vm = LibraryViewModel(repository: repo, initial: repo.load())

        let view = LibraryView(viewModel: vm)

        XCTAssertNotNil(view)
    }
}
