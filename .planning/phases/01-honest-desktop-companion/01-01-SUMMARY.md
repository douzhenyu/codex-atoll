---
phase: 01-honest-desktop-companion
plan: 01
subsystem: desktop
tags: [swiftui, appkit, xcode, xctest, macos, apache-2.0]

# Dependency graph
requires: []
provides:
  - "Buildable, attributable Codex Atoll app/test identity and shared scheme"
  - "Apache-2.0 LICENSE plus NOTICE pinning the upstream Claude Atoll snapshot"
  - "Bundled Codex mark asset ready for the Plan 02 native notch shell"
affects: [01-02, 01-03, 01-04, 01-05]

# Actuals (#2632) — same chars/4 scale as the plan's `estimate` (18000).
actuals:
  tokens: 9158
  tasks: 2
  commits: 3

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "App entry: @main SwiftUI App exposing only an empty Settings scene until the notch shell exists"
    - "Project graph: one app target + one XCTest target with empty package dependencies and no framework linkage"

key-files:
  created:
    - LICENSE.md
    - NOTICE
    - CodexAtoll.xcodeproj/project.pbxproj
    - CodexAtoll.xcodeproj/xcshareddata/xcschemes/CodexAtoll.xcscheme
    - CodexAtoll/App/CodexAtollApp.swift
    - CodexAtoll/Resources/Localizable.xcstrings
    - CodexAtoll/Resources/Assets.xcassets/Contents.json
    - CodexAtoll/Resources/Assets.xcassets/CodexMark.imageset/Contents.json
    - CodexAtoll/Resources/Assets.xcassets/CodexMark.imageset/codex-mark.svg
    - CodexAtollTests/.gitkeep
    - .gitignore
  modified: []

key-decisions:
  - "Use the reference Claude Atoll project as provenance source: preserve Apache-2.0 LICENSE and pin snapshot 4e7cf858faa3e013b73150a5e4d41355c4f5be4e in NOTICE"
  - "Development bundle identity is com.codexatoll.CodexAtoll; public Team/bundle/Sparkle identity is deferred to Phase 6"
  - "Empty Settings-scene entry creates no ordinary window or inherited runtime side effect until Plan 02 attaches the accessory lifecycle"

patterns-established:
  - "App entry pattern: @main SwiftUI App with empty Settings scene only; the accessory NSPanel and delegate arrive with the Plan 02 shell"
  - "Project wiring pattern: PBXFileSystemSynchronizedRootGroup source groups, generated Info.plist, Swift 6 strict concurrency, macOS 15.6 target"

requirements-completed: [DESK-01]

# Coverage metadata (#1602)
coverage:
  - id: D1
    description: "Attributed Codex Atoll app/test identity: Apache LICENSE + NOTICE, renamed app/XCTest targets, shared scheme, bundled Codex mark, empty Settings entry"
    requirement: DESK-01
    verification:
      - kind: other
        ref: "xcodebuild -list -project CodexAtoll.xcodeproj"
        status: pass
      - kind: other
        ref: "xcodebuild build -project CodexAtoll.xcodeproj -scheme CodexAtoll -configuration Debug"
        status: pass
      - kind: other
        ref: "source scan: rg for ClaudeAtoll|HookInstaller|HookSocketServer|TokenTrackingManager|SUFeedURL|SUPublicEDKey|CGEventPost|AXUIElement|UserDefaults|@AppStorage|ProgressView"
        status: pass
    human_judgment: false

# Metrics
duration: 40min
completed: 2026-08-18
status: complete
---

# Phase 01 Plan 01: Attributed Codex Atoll app/test identity Summary

**Buildable, attributable Codex Atoll macOS app and XCTest targets with Apache-2.0 provenance, a shared CodexAtoll scheme, bundled Codex mark, and an empty Settings-scene entry — with no inherited runtime side effect and no package dependency**

## Performance

- **Duration:** ~40 min (including the Task 1 human-verify checkpoint pause)
- **Started:** 2026-08-18 (prior executor; Task 1 commit `f1ea5fb` at 13:11 +0800)
- **Completed:** 2026-08-18 (Task 2 commit `d76d98d` at 13:28 +0800)
- **Tasks:** 2
- **Files modified:** 11 created

## Accomplishments
- Preserved the Apache-2.0 `LICENSE.md` and added `NOTICE` naming the upstream Claude Atoll project, pinned snapshot `4e7cf858faa3e013b73150a5e4d41355c4f5be4e`, license, and Codex Atoll modifications.
- Renamed app entry to `@main struct CodexAtollApp` exposing only an empty SwiftUI `Settings` scene — no ordinary window, server, database, auth, persistence, or inherited service.
- Built a macOS 15.6 app target and XCTest target (generated Info.plist, Swift 6 strict concurrency, test-host linkage) plus a shared `CodexAtoll` app/test scheme.
- Added the Codex mark as a bundled, template-rendered vector asset; no Claude product artwork was copied.
- Proved the target/dependency inventory: `xcodebuild -list` reports exactly `CodexAtoll` + `CodexAtollTests` + shared scheme, and the Debug build exits 0 under the full-Xcode precondition.

## Task Commits

Each task was committed atomically:

1. **Task 1: Build the attributed Codex Atoll app target end to end** - `f1ea5fb` (feat)
2. **Task 2: Prove the target and dependency inventory** - `d76d98d` (chore, empty commit — audit required no corrections)

**Plan metadata:** (final docs commit for this SUMMARY + STATE/ROADMAP)

## Files Created/Modified
- `LICENSE.md` - Apache-2.0 license retained from the reference source
- `NOTICE` - Upstream snapshot and modification attribution
- `CodexAtoll.xcodeproj/project.pbxproj` - One application + one XCTest target, empty package/framework graphs, Swift 6 settings, macOS 15.6
- `CodexAtoll.xcodeproj/xcshareddata/xcschemes/CodexAtoll.xcscheme` - Shared app/test build-and-test scheme
- `CodexAtoll/App/CodexAtollApp.swift` - `@main` SwiftUI entry with empty Settings scene
- `CodexAtoll/Resources/Localizable.xcstrings` - Empty localization catalog foundation
- `CodexAtoll/Resources/Assets.xcassets/Contents.json` - Asset catalog root
- `CodexAtoll/Resources/Assets.xcassets/CodexMark.imageset/Contents.json` - Codex mark metadata (template, preserves-vector)
- `CodexAtoll/Resources/Assets.xcassets/CodexMark.imageset/codex-mark.svg` - Bundled Codex mark vector
- `CodexAtollTests/.gitkeep` - Placeholder until Plan 02 adds CapabilityContractTests
- `.gitignore` - Ignore build/DerivedData artifacts

## Decisions Made
- Reused the Claude Atoll reference project as the provenance source, preserving its Apache-2.0 license rather than reimplementing attribution.
- Deferred all public signing/Team/Sparkle feed identity to Phase 6; development identity is `com.codexatoll.CodexAtoll` with no `DEVELOPMENT_TEAM`.
- Kept the app entry dependency-free and window-free so no inherited startup service can run before the notch shell exists.

## Deviations from Plan
None - plan executed exactly as written.

## Issues Encountered
- None. Task 2 was a pure audit: the graph produced by Task 1 already satisfied every acceptance criterion (`xcodebuild -list` shape, empty package/dependency lists, no signing identity, clean identity scan), so no corrections were required and the task commit is empty by design.

## User Setup Required
None - no external service configuration required. Full Xcode (26.6) was verified selected before execution per the task precondition.

## Next Phase Readiness
- Plan 02 can add `@NSApplicationDelegateAdaptor` + `AppDelegate` and the native accessory `NSPanel` lifecycle without revisiting project/scheme wiring.
- The bundled Codex mark (`CodexMark.imageset`) is available to the notch shell (DESK-01 / D-01).
- `CodexAtollTests` target and shared scheme are ready for `CapabilityContractTests` in Plan 02.

---
*Phase: 01-honest-desktop-companion*
*Completed: 2026-08-18*

## Self-Check: PASSED
- All 10 plan files verified present on disk (LICENSE.md, NOTICE, project.pbxproj, shared scheme, app entry, localization catalog, asset catalog root, CodexMark imageset contents, codex-mark.svg, CodexAtollTests/.gitkeep).
- SUMMARY.md present at `.planning/phases/01-honest-desktop-companion/01-01-SUMMARY.md`.
- Task commits verified in git history: `f1ea5fb` (Task 1) and `d76d98d` (Task 2).
