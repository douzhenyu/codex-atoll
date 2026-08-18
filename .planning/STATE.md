---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
current_phase: 01
current_phase_name: Honest Desktop Companion
status: executing
stopped_at: Completed 01-03-PLAN.md
last_updated: "2026-08-18T06:07:29.098Z"
last_activity: 2026-08-18
last_activity_desc: Phase 01 execution started
progress:
  total_phases: 1
  completed_phases: 0
  total_plans: 5
  completed_plans: 3
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-17)

**Core value:** Codex users can notice and handle tasks that need attention without interrupting their current workflow.
**Current focus:** Phase 01 — Honest Desktop Companion

## Current Position

Phase: 01 (Honest Desktop Companion) — EXECUTING
Plan: 4 of 5
Status: Ready to execute
Last activity: 2026-08-18 — Phase 01 execution started

Progress: [██████░░░░] 60%

## Performance Metrics

**Velocity:**

- Total plans completed: 0
- Average duration: -
- Total execution time: 0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| - | - | - | - |

**Recent Trend:**

- Last 5 plans: -
- Trend: Not enough data

**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 01-honest-desktop-companion P01 | 40 | 2 tasks | 11 files |
| Phase 01-honest-desktop-companion P01-02 | 11 | 2 tasks | 10 files |
| Phase 01-honest-desktop-companion P01-03 | 10 | 2 tasks | 8 files |

## Accumulated Context

### Decisions

Recent decisions affecting current work:

- [Milestone v1]: Adapt Claude Atoll's macOS shell rather than reimplementing it.
- [Milestone v1]: Ship Codex CLI and Desktop together; Desktop v1 is source-labelled activation and explicit fallback only.
- [Milestone v1]: Direct approvals require an authenticated, live, request-scoped official integration; otherwise return to native Codex.
- [Milestone v1]: Public distribution requires a signed, notarized DMG and a signed Sparkle feed.
- [Phase 01]: Use the reference Claude Atoll project as provenance source: preserve Apache-2.0 LICENSE and pin snapshot 4e7cf858faa3e013b73150a5e4d41355c4f5be4e in NOTICE
- [Phase 01]: Development bundle identity is com.codexatoll.CodexAtoll; public Team/bundle/Sparkle identity is deferred to Phase 6
- [Phase 01]: Empty Settings-scene entry creates no ordinary window or inherited runtime side effect until Plan 02 attaches the accessory lifecycle
- [Phase 01]: Keep one NotchWindowController directly in AppDelegate (no WindowManager abstraction) and recreate it on screen changes guarded by display ID
- [Phase 01]: Window frame tracks the visible pill/panel so the closed pill accepts native clicks; the reference's global-monitor open is replaced because CGEvent monitors are forbidden in Phase 1
- [Phase 01]: Contract tests run @MainActor because the app target sets SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor
- [Phase ?]: One capability class per whole card: the Desktop card is currentlyUnobservable (eye.slash); available/jumpOnly exist in the vocabulary but are reserved for later verified/owned sessions
- [Phase ?]: The launcher owns an ordered compile-time identifier set containing only the verified com.openai.codex; no aliases, deep links, or UI automation are guessed
- [Phase ?]: The handoff races the native request against a five-second production timeout (injectable in tests), coalesces while .opening, and maps lookup/open/activation/timeout to explicit local results
- [Phase ?]: WorkspaceOpening exposes only lookup/open/activate; SystemWorkspace is the AppKit implementation and the test fake is the only other conformer

### Pending Todos

None yet.

### Blockers/Concerns

- Existing Codex Desktop tasks have no verified public third-party history, task-control, or approval API; preserve the activation-only fallback.
- Verify current Codex hooks and App Server protocols during phase planning; disable direct control on incompatibility.

## Deferred Items

| Category | Item | Status | Deferred At |
|----------|------|--------|-------------|
| Desktop integration | Per-task monitoring, history, deep links, and direct approval require an official public API. | Deferred | 2026-08-17 |
| Existing CLI history | Complete import of arbitrary existing CLI history requires a stable documented interface. | Deferred | 2026-08-17 |
| Usage | Account-wide numeric quota needs an official API. | Deferred | 2026-08-17 |

## Session Continuity

Last session: 2026-08-18T06:07:20.886Z
Stopped at: Completed 01-03-PLAN.md
Resume file: None
