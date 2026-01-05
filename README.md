# Wellobit – Breathing Session Workout  
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

## Notes
- The items above describe the **logic and behavior** of the breathing session, not final visual design.
- The breathing flow, timing, background handling, and audio behavior are implemented using **Clean Architecture**, separating logic from UI design.
- Because of this separation:
  - The **background visuals** (colors, images, animations) can be changed later without affecting the breathing logic.
  - The **sound or audio style** (e.g. birds, silence, different ambience) can be easily replaced or adjusted without reworking the session flow.
- The current implementation prioritizes **correct behavior, background support, and stability**.
- Once the design direction is finalized, visual and audio refinements can be applied safely and quickly.


