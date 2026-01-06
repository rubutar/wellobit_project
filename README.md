# Wellobit – Breathing Session Workout  

```
BreathingSession
├── Application
│   └── WellobitApp.swift
│
├── Domain
│   ├── Entities
│   │   ├── BreathingPhase.swift
│   │   ├── BreathingSettings.swift
│   │   └── BreathingPreset.swift
│   │
│   └── UseCases
│       ├── StartBreathingSessionUseCase.swift
│       └── UpdateBreathingSettingUseCase.swift
│
├── Data
│   ├── Repositories
│   │   ├── BreathingRepository.swift
│   │   └── LocalBreathingRepository.swift
│
├── Presentation
│   ├── ViewModels
│   │   ├── BreathingPlayerViewModel.swift
│   │   ├── LibraryViewModel.swift
│   │   └── BreathingViewModel.swift
│   │
│   ├── Views
│   │   ├── BreathingPlayer.swift
│   │   ├── BreathingCircle.swift
│   │   ├── BreathingPhaseSelector.swift
│   │   ├── HomeView.swift
│   │   └── LibraryView.swift
│   │
│   └── Router
│       └── TabRouter.swift
│
└── Resources
    ├── Audio
    │   ├── birds.mp3
    │   ├── inhale.mpeg
    │   ├── exhale.mpeg
    │   └── hold.mpeg
    │
    └── Assets
        └── river.xcassets
```

**Date:** 5 January 2026
## What has been completed on this screen
- Guided breathing session with:
  - Inhale
  - Hold In
  - Exhale
  - Hold Out
- Customizable duration for each breathing phase
- Selectable breathing cycle count
- Preparation countdown before the session starts (“Get Ready”)
- Breathing animation synced with breathing phases
- Play, pause, resume, and cancel controls
- Remaining time indicator for each breathing phase
- Cycle progress indicator (current cycle / total cycles)
- Ambient background audio during the breathing session
- Audio continues playing when the phone screen is locked
- Mute / unmute control for background audio (just apply when the player is active)
- Session completion state (“Well done”)
- When the value of the phase and cycle changed, the session should be back inactive (active session should be cancelled).
- Add cues for each phase (inhale, exhale, hold)
- Add preset library and hold in/hold out value can be zero/skipped.

## Notes
- The items above describe the **logic and behavior** of the breathing session, not the final visual design.
- The breathing flow, timing, background handling, and audio behavior are implemented using **Clean Architecture**, separating logic from UI design.
- Because of this separation:
  - The **background visuals** (colors, images, animations) can be changed later without affecting the breathing logic.
  - The **sound or audio style** (e.g. birds, silence, different ambience) can be easily replaced or adjusted without reworking the session flow.
- The current implementation prioritizes **correct behavior, background support, and stability**.
- **The breathing session is not yet connected to Apple Health / Mindfulness (HealthKit)**.
  - This can be added later once the breathing experience and session rules are finalized.
- **iOS version targeting, glass-style visual effects, and Dark Mode styling are not configured yet**.
  - These will be addressed after the final design direction is confirmed.
- Once the design, platform targets, and HealthKit direction are confirmed, visual, audio, and system integrations can be applied safely and quickly.
