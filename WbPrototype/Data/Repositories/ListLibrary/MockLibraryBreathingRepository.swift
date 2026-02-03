//
//  MockLibraryBreathingRepository.swift
//  WbPrototype
//
//  Created by Rudi Butarbutar on 01/02/26.
//

//struct BreathingSession: Identifiable, Equatable {
//    let id: String
//    let title: String
//    let subtitle: String
//    let description: String
//    let tip: String
//
//    let category: BreathingCategory
//    let imageName: String
//    let diagramImage: String
//    let preset: BreathingPreset
//}

final class MockLibraryBreathingRepository: LibraryBreathingRepository {
    func fetchLibrarySessions() -> [BreathingSession] {
        [
            BreathingSession(
                id: "box",
                title: "Box Breathing",
                subtitle: "Feel steady again",
                description:
                    """
                    A simple breathing technique to calm your nervous system and restore focus through steady, balanced breaths.
                    """,
                tip: "💡 Go gently. Shorten holds if needed.",
                category: .calm,
                imageName: "calm_1",
                diagramImage: "calm_1_diag",
                preset: .box

            ),
            BreathingSession(
                id: "long_exhale",
                title: "Long Exhale",
                subtitle: "Let go of tension",
                description:
                    """
                    A patterned breathing technique that builds calm, control, and focus through repeated inhale, hold, exhale, and pause.
                    """,
                tip: "💡 Tip: Shorten length if needed",
                category: .calm,
                imageName: "calm_2",
                diagramImage: "calm_2_diag",
                preset: .longExhale
            ),
            BreathingSession(
                id: "coherent",
                title: "Coherent Breath",
                subtitle: "Settle into flow",
                description:
                    """
                    A balanced breathing technique that promotes relaxation by keeping inhale and exhale equal.
                    """,
                tip: "💡 Tip: Breathe evenly. Adjust pace if needed.",
                category: .focus,
                imageName: "focus_1",
                diagramImage: "focus_1_diag",
                preset: .cBreath
            ),
            BreathingSession(
                id: "energizing",
                title: "Energizing Breath",
                subtitle: "Feel clear and awake",
                description:
                    """
                    A quick, rhythmic breathing technique to boost alertness and energy.
                    """,
                tip: "💡 Tip: Keep it steady and lively.",
                category: .focus,
                imageName: "focus_2",
                diagramImage: "focus_2_diag",
                preset: .eBreath
            ),
            BreathingSession(
                id: "sleep",
                title: "Breathe for Sleep",
                subtitle: "Drift into deeper sleep",
                description:
                    """
                    A gentle, calming breathing practice to help you relax and fall asleep faster.
                    """,
                tip: "💡 Tip: Breathe slowly. Let go of tension.",
                category: .rest,
                imageName: "rest_1",
                diagramImage: "rest_1_diag",
                preset: .sleep
            ),
            BreathingSession(
                id: "478",
                title: "4-7-8 Breathing",
                subtitle: "Deep calm & sleep",
                description:
                    """
                    A relaxing technique that helps reduce stress and promote calm by controlling inhale, hold, and exhale durations.
                    """,
                tip: "💡 Tip: Breathe slowly. Let go of tension.",
                category: .rest,
                imageName: "rest_2",
                diagramImage: "rest_2_diag",
                preset: .fourSevenEight
            )
        ]
    }
}
