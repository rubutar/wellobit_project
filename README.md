# Wellobit – Breathing Session Workout  

```
Wellobit
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

**Date:** 8 January 2026
- Haptics added to breathing phases:
  - Distinct haptic feedback for inhale, exhale, and hold phases
  - Haptics triggered on phase transitions
  - Consistent behavior across pause / resume
- Scene system added for guided breathing sessions
  - Waterfall, River, and Beach scenes
- Scene selection screen with horizontal scrollable cards
- Persistent scene selection using local repository (UserDefaults)
- Scene settings navigation:
  - Settings button added to the breathing screen
  - Navigates to scene selection screen
  - Active breathing session is cancelled when entering scene settings
- Background image dynamically updates based on selected scene
- Background ambient audio dynamically updates based on selected scene
- Seamless scene switching while session is active:
  - Audio restarts with the newly selected scene
  - Playback respects mute state

**Date:** 9 January 2026
- - Cycle configuration improvements:
  - Cycle count expanded from 1–10 to 1–60
  - Cycle duration dynamically calculated based on phase settings
  - UI now displays both cycle count and total estimated duration
- Cycle selector UI refactor:
  - Replaced cycle dropdown menu with an inline slider
  - Slider placed below phase configuration for better discoverability
  - Live duration text updates as the slider moves
- Breathing player layout stabilization:
  - Phase selector hidden during active breathing session
  - Scene settings toolbar button hidden while session is active
- Breathing animation improvements:
  - Smooth breathing animation driven by elapsed time
  - Animation correctly pauses and resumes without restarting phases
- Pre-session user guidance:
  - Pre-session warning shown before starting breathing
- Apple Watch communication:
  - Pre-session message sent from iOS to Apple Watch
  - Watch receives cycle count and total duration
  - Watch pre-session reminder view implemented

**Date:** 9 January 2026
- LibraryView & BreathingPhaseSelector stabilization
  - Fixed layout shifting issues caused by overlapping `ZStack` layers
  - Ensured floating overlays (phase editor) no longer push or resize the main layout
  - Phase editor now correctly overlays the phase selector instead of affecting screen height
  -  Improved layout consistency between inactive and active session states

- Breathing phase editor UX improvements
  - Refined expanded phase editor visual style for better readability in light mode
  - Improved contrast for text, sliders, and controls using adaptive system colors
  - Updated phase editor header hierarchy (title, value, close action)
  - Close button visually highlighted with clear affordance and larger tap target

- Interaction & behavior fixes
  - Ensured expanded phase editor dismisses cleanly without layout jump
  - Phase selection state properly resets after closing editor
  - Reduced accidental interaction conflicts between cycle editor and phase selector
  - Improved overall touch hit-testing reliability for overlay controls

- Code structure & maintainability
  - Simplified overlay logic to use a single, stable `ZStack` root
  - Improved separation between selector content and overlay content for future extensibility

- Floating controls & navigation behavior updates
  - Refactored floating control layout in `BreathingPlayer` to use proper `ZStack` layering
  - Floating buttons are now visually anchored to the bottom-right corner of the player area
  - Removed layout side effects caused by `Spacer` usage in overlay containers
  - Ensured floating controls no longer affect surrounding views (phase selector, player layout)

- Navigation simplification (NavigationStack → Modal)
  - Removed nested `NavigationStack` usage inside the breathing flow
  - Replaced scene navigation with modal presentation (`sheet`)
  - Scene selection now opens as a modal overlay instead of a pushed navigation screen
  - Modal presentation prevents layout conflicts and unexpected navigation state resets
  - Active breathing session is safely cancelled before presenting scene selection modal

- UX improvements from modal-based navigation
  - Scene selection feels lighter and more contextual to the breathing session
  - Users can dismiss scene selection via swipe-down without breaking navigation state
  - Reduced cognitive load by avoiding deep navigation for quick configuration tasks
  - Improved consistency between inactive and active session flows



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



# Wellobit – Live Activity

```
Wellobit
├── Data
│   ├── LiveActivity
│   │   ├── BreathingLiveActivityAttributes.swift
│   │   └── BreathingLiveActivityController.swift
│   ├── Presentation
│   │   └── ViewModels
│   │   │   └── BreathingPlayerViewModel.swift

WellobitWidgetExtension
├── WellobitActivity
│   └── BreathingLiveActivityWidget.swift
├── Assets
├── Info
└── WellobitWidgetExtensionBundle.swift

```

**Date:** 6 January 2026
## What has been completed on this screen
- Implemented Live Activity support for the breathing session using ActivityKit.
- Added Dynamic Island UI:
  - Compact state: icon on the left, remaining time on the right.
  - Expanded state: breathing phase (Inhale / Hold / Exhale) and countdown timer.
  - Minimal state: icon-only display.
- Added Lock Screen Live Activity UI showing:
  - Current breathing phase.
  - Remaining seconds.
- Implemented a dedicated Live Activity controller in the main app to:
  - Start the Live Activity when the breathing session begins.
  - Update phase and remaining time during the session.
  - End the Live Activity when the session completes or is cancelled.
- Properly separated logic (app target) and UI (widget extension target) following Apple’s Live Activity architecture.
- Ensured the breathing session can continue and remain visible via Live Activity when the app is backgrounded or the screen is locked.

Notes
- This implementation focuses on the logic flow and system behavior, not final visual design.



# Wellobit – Sleep tracking

<img width="117" height="255" alt="image" src="https://github.com/user-attachments/assets/808aa3f0-0e78-442e-8c13-120ea9ad46f6" />

**Date:** 10 January 2026
## What has been completed on this screen
- Implemented **HealthKit sleep permission flow**
  - Requested read access for:
    - Sleep Analysis
    - Heart Rate
    - HRV (SDNN)
    - Respiratory Rate
- Implemented **latest sleep session fetching**
  - Retrieved last night’s sleep window from HealthKit
  - Corrected sleep grouping logic to use **wake-up date (endDate)** instead of startDate
  - Displayed:
    - Total sleep duration
    - Sleep time range (start → end)
- Implemented **sleep stage breakdown**
  - Parsed sleep stages (Awake, REM, Core, Deep)
  - Aggregated duration per stage
  - Displayed stage durations in the Sleep Details section
- Implemented **historical sleep data fetching**
  - Fetched daily sleep summaries for:
    - 1 Week
    - 2 Weeks
    - 1 Month
    - 3 Months
  - Ensured missing days are handled gracefully (no data → 0 duration)
- Implemented **average metrics calculation per timeframe**
  - Average sleep duration
  - Average heart rate
  - Average HRV
  - Average respiratory rate
  - Designed averages to remain visible even if optional metrics are unavailable

**Date:** 11 January 2026
- Implemented **Sleep Score system**
  - Designed sleep score input pipeline using:
    - Sleep duration
    - Bedtime consistency
    - Sleep heart rate vs baseline
    - Sleep HRV vs baseline
  - Built a dedicated **SleepScoreInputBuilder** to aggregate sleep + vitals data
  - Implemented **SleepScoreCalculator**
  - Validated score alignment with **Apple Health Sleep Score**
- Implemented **date-based sleep navigation**
  - Added previous / next day navigation
  - 
**Date:** January 12, 2026
## Daily Progress Update

### January 12, 2026
- Implemented **Stress Score modeling**
  - Built stress scoring pipeline using raw **Sleep**, **Heart Rate** and **HRV** data
  - Ensured accurate stress computation by separating raw physiological data from derived metrics
- Stabilized **stress and modeled stress data flow**
  - Fixed async dependency issues between HR, HRV, and stress calculations
- Improved **date-based data refresh**
  - Stress and sleep data now update reliably when navigating between dates
- Refined **stress visualizations**
  - Eliminated misleading zero / flatline values
  - Improved accuracy and reliability of 24-hour stress charts
 
### January 13, 2026
- Implemented Stress Peak detection logic
  - Uses a window-based (30-minute) sustained peak model
  - Detects multiple peak points across the day (not a single max spike)
  - Marks peak points visually on the stress chart
- Implemented Peak Stress % calculation
  - Based on average of window peaks
  - Normalized the data
- Added data sufficiency validation
  - Peak Stress shows -- when there is insufficient real stress data
  - Avoids misleading values on sparse or empty days
- Refined Stress Chart rendering
  - Breaks lines when data is missing
  - Ensures peak markers align with actual stress values
