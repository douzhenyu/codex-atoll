---
phase: 01-honest-desktop-companion
plan: 02
subsystem: desktop
tags: [swiftui, appkit, xcode, xctest, macos, apache-2.0]

# Dependency graph
requires:
  - phase: 01-01
    provides: "Attributed app/test identity, shared CodexAtoll scheme, bundled Codex mark, empty Settings entry"
provides:
  - "Native nonactivating accessory panel that tracks its frame to the visible pill/panel so closed clicks are native"
  - "Window-only AppDelegate lifecycle with screen-change placement only"
  - "Local closed/open shell model plus the single source-labelled companion route"
  - "Runnable CapabilityContractTests gate that fails if the shell implies Desktop observability or inherited side effects"
affects: [01-03, 01-04, 01-05]

# Actuals (#2632) — same chars/4 scale as the plan's `estimate` (24000).
actuals:
  tokens: 8416
  tasks: 2
  commits: 3

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Window frame tracks the visible panel so the closed pill accepts native clicks without global event monitors or CGEvent reposting"
    - "AppKit placement via a newest-value AsyncStream (bufferingNewest(1)) consumed by the window controller"
    - "MainActor XCTest: app target uses SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor, so the contract test class is @MainActor"

key-files:
  created:
    - CodexAtoll/App/AppDelegate.swift
    - CodexAtoll/Core/NotchGeometry.swift
    - CodexAtoll/Core/NotchViewModel.swift
    - CodexAtoll/UI/Views/NotchView.swift
    - CodexAtoll/UI/Window/NotchWindowController.swift
    - CodexAtoll/UI/Window/NotchViewController.swift
    - CodexAtollTests/CapabilityContractTests.swift
  modified:
    - CodexAtoll/App/CodexAtollApp.swift
    - CodexAtoll/Resources/Localizable.xcstrings
    - .gitignore

key-decisions:
  - "Keep one NotchWindowController directly in AppDelegate (no WindowManager abstraction) and recreate it on screen changes guarded by display ID"
  - "Define NotchPanel inside NotchWindowController.swift so the plan's file list is honoured while exporting NotchPanel"
  - "Track the window frame to the closed pill / opened panel so a direct native click opens the route; the reference's global-monitor open is replaced because CGEvent monitors are forbidden"
  - "Centralize view copy in NotchStrings so the VoiceOver collapsed label is a testable, localized contract"

patterns-established:
  - "Shell entry: @NSApplicationDelegateAdaptor + accessory activation policy + single NotchWindowController"
  - "Local route pattern: NotchStatus (closed/open) + NotchDestination (companion) carry no task/account/credential data"
  - "Panel placement pattern: status stream drives window.setFrame to closedScreenRect/openedScreenRect"
  - "Bounded hit testing: PassThroughHostingView accepts hits only within the hosting bounds"
  - "Source-inventory gate: CapabilityContractTests scans app Swift sources for forbidden inherited identifiers"

requirements-completed: [DESK-01]

# Coverage metadata (#1602)
coverage:
  - id: D1
    description: "Native accessory-panel shell that launches window-only, starts collapsed with Codex mark + neutral eye.slash, and opens a local source-labelled companion route on direct click"
    requirement: DESK-01
    verification:
      - kind: other
        ref: "xcodebuild build -project CodexAtoll.xcodeproj -scheme CodexAtoll -configuration Debug"
        status: pass
      - kind: other
        ref: "source scan: rg for HookInstaller|HookSocketServer|TokenTrackingManager|ClaudeSessionMonitor|SUFeedURL|SUPublicEDKey|claudeatoll.engels74.net|CGEventPost|AXUIElement|ProgressView|UserDefaults|@AppStorage in CodexAtoll/"
        status: pass
      - kind: other
        ref: "launch smoke: CodexAtoll.app process stays alive with empty stderr"
        status: pass
      - kind: unit
        ref: "CodexAtollTests/CapabilityContractTests.swift#testFreshModelStartsClosedWithCompanionDestination, #testDirectOpenThenCloseKeepsLocalRoute, #testCollapsedAccessibilityLabelIsCompleteForVoiceOver, #testCollapsedShellHasNoTaskOrProgressState"
        status: pass
    human_judgment: false
  - id: D2
    description: "Runnable shell contract test gate: transitions, single local route, collapsed VoiceOver label, and forbidden production inventory"
    verification:
      - kind: unit
        ref: "xcodebuild test -project CodexAtoll.xcodeproj -scheme CodexAtoll -destination 'platform=macOS' -only-testing:CodexAtollTests/CapabilityContractTests"
        status: pass
      - kind: unit
        ref: "CodexAtollTests/CapabilityContractTests.swift#testProductionInventoryRejectsInheritedServicesAndPersistence"
        status: pass
    human_judgment: false
  - id: D3
    description: "Manual runtime smoke: neutral collapsed state, direct click-to-expand, local close, keyboard focus, VoiceOver label, and no automatic expansion"
    verification: []
    human_judgment: true
    rationale: "Requires a running macOS window and visual/accessibility inspection (WindowServer, VoiceOver). VALIDATION.md lists this as a manual-only verification for end-of-phase UAT."

# Metrics
duration: 11min
completed: 2026-08-18
status: complete
---

# Phase 01 Plan 02: Native collapsed/open notch shell Summary

**Window-only native accessory panel with a local closed/open shell, the bundled Codex mark plus neutral `eye.slash` collapsed state, a source-labelled `Codex Desktop` companion route, and a MainActor contract test gate that rejects inherited Desktop observability**

## Performance

- **Duration:** ~11 min
- **Started:** 2026-08-18T05:33:02Z
- **Completed:** 2026-08-18T05:43:52Z
- **Tasks:** 2
- **Files modified:** 10 (7 created, 3 modified)

## Accomplishments
- `@NSApplicationDelegateAdaptor` + `AppDelegate` start the app as a window-only accessory: accessory activation policy, one `NotchWindowController`, and display-ID-guarded screen-change placement — no hook, socket, updater, accessibility, or background integration.
- `NotchPanel`/`NotchWindowController` own the native nonactivating panel. The window frame tracks the visible pill/panel so the collapsed pill accepts a **direct native click** to open the companion route, replacing the reference's global-event-monitor open (CGEvent monitoring is forbidden).
- `NotchViewModel` owns exactly closed/open status, the `.companion` local route, the newest-value AppKit status stream, and direct-click open/close. It carries no Desktop lifecycle, task, approval, progress, integration, or credential state.
- `NotchView` renders the collapsed Codex mark (left) + static neutral `eye.slash` (right) with the complete VoiceOver label `Codex Atoll. Codex Desktop is currently unobservable.`, and the expanded route renders the source-labelled `Codex Desktop` / `Currently unobservable` companion card with the exact UI-SPEC explanation — no spinner, skeleton, shortcut button, or automatic expansion.
- `CapabilityContractTests` proves fresh/closed/open routing, the single local route, the complete collapsed accessibility label, and a forbidden source-inventory scan. The focused XCTest class passes and the source scan stays clean.

## Task Commits

Each task was committed atomically:

1. **Task 1: Launch the native collapsed/open notch path** - `c7e5bd7` (feat)
2. **Task 2: Prove the shell state and accessibility contract** - `68607d9` (test, RED) + `b12a859` (feat, GREEN)

**Plan metadata:** (final docs commit for this SUMMARY + STATE/ROADMAP)

## Files Created/Modified
- `CodexAtoll/App/AppDelegate.swift` - Window-only accessory lifecycle: activation policy, single notch controller, display-ID-guarded screen-change placement
- `CodexAtoll/App/CodexAtollApp.swift` - `@main` entry now attaches `AppDelegate` via `@NSApplicationDelegateAdaptor`; Settings scene stays empty
- `CodexAtoll/Core/NotchGeometry.swift` - Pure pill/panel geometry plus `NSScreen` notch helpers (notch size, built-in display, physical-notch detection)
- `CodexAtoll/Core/NotchViewModel.swift` - `NotchStatus` (closed/open), `NotchDestination` (companion), and the `@Observable` model with the newest-value status stream
- `CodexAtoll/UI/Views/NotchView.swift` - `NotchShape`, localized `NotchStrings`, collapsed pill (mark + neutral symbol) and expanded companion card; tap toggles, Escape closes
- `CodexAtoll/UI/Window/NotchWindowController.swift` - `NotchPanel` (borderless nonactivating panel) and controller that tracks the window frame to the closed/open rect via the status stream
- `CodexAtoll/UI/Window/NotchViewController.swift` - `PassThroughHostingView` with bounded hit testing hosting the SwiftUI shell
- `CodexAtollTests/CapabilityContractTests.swift` - Shell transitions, route, accessibility, and forbidden-inventory contract tests (`@MainActor`)
- `CodexAtoll/Resources/Localizable.xcstrings` - Localized shell copy (collapsed accessibility label, source, capability, card body, close hint)
- `.gitignore` - Ignore `*.profraw` coverage output produced when the app is launched

## Decisions Made
- Kept one `NotchWindowController` directly in the delegate (no window-manager abstraction) and recreate on screen change only when the display ID actually changes.
- Made the window frame match the visible content so the closed pill is natively clickable; this is required because Phase 1 forbids global event monitors and CGEvent reposting that the reference relies on.
- Defined `NotchPanel` inside `NotchWindowController.swift` to honour the plan's file list while still exporting `NotchPanel`.
- Centralized view copy in `NotchStrings` so the collapsed VoiceOver contract is testable and localized via the string catalog.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Contract tests could not compile against the MainActor-isolated app target**
- **Found during:** Task 2 (RED phase)
- **Issue:** The app target builds with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, but the `CodexAtollTests` target has no such default, so the tests failed to compile (`Call to main actor-isolated initializer`, `Main actor-isolated property ... can not be referenced from a nonisolated context`).
- **Fix:** Annotated `CapabilityContractTests` with `@MainActor` so the XCTest class runs on the same actor model as the app. This was the TDD GREEN step.
- **Files modified:** `CodexAtollTests/CapabilityContractTests.swift`
- **Verification:** `xcodebuild test ... -only-testing:CodexAtollTests/CapabilityContractTests` — all 5 tests pass.
- **Committed in:** `b12a859` (Task 2 GREEN commit)

**2. [Rule 3 - Housekeeping] Coverage profile output generated on app launch**
- **Found during:** Task 1 (launch smoke)
- **Issue:** Launching the built app created `default.profraw` in the working directory.
- **Fix:** Added `*.profraw` to `.gitignore` and removed the generated file.
- **Files modified:** `.gitignore`
- **Verification:** `git status` clean of generated coverage files.
- **Committed in:** `c7e5bd7` (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (2 blocking/housekeeping)
**Impact on plan:** Both were necessary to satisfy the plan's automated verify commands. No scope creep; the plan file list was honoured.

## Issues Encountered
- The Task 2 RED gate genuinely failed (test target vs MainActor app target mismatch), so the TDD gate is fully compliant: a `test(01-02)` commit (`68607d9`) was followed by a `feat(01-02)` commit (`b12a859`). No RED-too-quick concern applies.
- `CodexAtollTests/.gitkeep` was intentionally removed in the RED commit as the Plan 01 placeholder it was created to be (replaced by `CapabilityContractTests.swift`).

## TDD Gate Compliance
- RED gate: `68607d9 test(01-02): add failing shell state and accessibility contract tests` — the tests failed to compile (MainActor mismatch), a genuine failing gate.
- GREEN gate: `b12a859 feat(01-02): run contract tests against the MainActor app target` — all 5 contract tests pass.
- REFACTOR: not needed; the GREEN fix was minimal and no further cleanup was warranted.

## User Setup Required
None - no external service configuration required. Full Xcode (26.6) was verified selected before execution per the task precondition.

## Next Phase Readiness
- Plan 03 can enrich the existing companion card (complete `Currently unobservable` card, `Open ChatGPT` launcher) without changing the route architecture: `NotchDestination.companion`, `NotchView.companionContent`, and the status-stream placement are stable.
- The bundled Codex mark, localized shell copy, and the MainActor contract-test pattern are in place for Plans 03-05.
- Manual runtime smoke (visual collapsed state, click-to-expand, local close, keyboard focus, VoiceOver label, no auto-expansion) remains for end-of-phase human UAT (coverage D3).

---
*Phase: 01-honest-desktop-companion*
*Completed: 2026-08-18*

## Self-Check: PASSED
- All 7 created source/test files verified present on disk (AppDelegate, NotchGeometry, NotchViewModel, NotchView, NotchWindowController, NotchViewController, CapabilityContractTests).
- SUMMARY.md present at `.planning/phases/01-honest-desktop-companion/01-02-SUMMARY.md`.
- Task commits verified in git history: `c7e5bd7` (Task 1), `68607d9` (Task 2 RED), `b12a859` (Task 2 GREEN).
