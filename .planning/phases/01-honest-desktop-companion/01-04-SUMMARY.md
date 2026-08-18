---
phase: 01-honest-desktop-companion
plan: 04
subsystem: desktop
tags: [swiftui, appkit, xcode, xctest, macos, apache-2.0]

# Dependency graph
requires:
  - phase: 01-03
    provides: "Complete honest Desktop card, CapabilityClass/CapabilityBadge vocabulary, coalesced DesktopHandoffLauncher, localized copy pattern"
provides:
  - "In-notch usage-unavailable detail and official handoff: fixed top-left `Usage unavailable` affordance, local `.usageUnavailable` route, exact official URL handoff that never fetches/estimates quota or reads credentials"
  - "Accessible local menu: top-right `Open Codex Atoll menu` control, native 44px `MenuRow`, and a four-row `NotchMenuView` (Open ChatGPT / Open official Codex usage / Back / Quit) dispatched through the tested launcher"
  - "Usage/menu accessibility and layout resilience: constrained-height scrolling, body wrap with full VoiceOver, CTA on its own row, bounded Opening feedback, retryable errors on owning surfaces"
affects: [01-05]

# Actuals (#2632) — same chars/4 scale as the plan's `estimate` (30000).
actuals:
  tokens: 7173
  tasks: 2
  commits: 4

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Payload-free local destinations: NotchDestination grew to companion/usageUnavailable/menu with no associated values, so no route can carry quota, history, or account data"
    - "Bounded URL handoff: WorkspaceOpening gains a default-browser `open(_:)` seam; openOfficialUsage() reuses the exact coalesced task-group race and five-second production timeout"
    - "Testable menu descriptor: NotchMenuView exposes an ordered, Equatable `MenuItem`/`Action` descriptor set rendered as native 44px buttons"
    - "No-bare-workspace gate: contract scan proves SwiftUI view/component files never call NSWorkspace directly"

key-files:
  created:
    - CodexAtoll/UI/Views/UsageUnavailableView.swift
    - CodexAtoll/UI/Views/NotchMenuView.swift
    - CodexAtoll/UI/Components/MenuRow.swift
  modified:
    - CodexAtoll/Core/DesktopHandoffLauncher.swift
    - CodexAtoll/Core/NotchViewModel.swift
    - CodexAtoll/Resources/Localizable.xcstrings
    - CodexAtoll/UI/Views/NotchView.swift
    - CodexAtollTests/CapabilityContractTests.swift
    - CodexAtollTests/DesktopHandoffLauncherTests.swift

key-decisions:
  - "The official usage handoff is the full data boundary: a single compile-time `officialUsageURL` constant opened in the default browser, with no fetch, embed, parse, cache, estimate, or retained page/account value"
  - "Routing stays payload-free and in-place: `.usageUnavailable` and `.menu` carry no associated data; Back returns to `.companion` and never closes the notch"
  - "Each external surface owns its launcher instance, so the usage detail, Desktop card, and menu each render bounded `Opening…` feedback and their exact retryable error on their own surface"
  - "The menu carries only product-relevant rows (Open ChatGPT, Open official Codex usage, Back, Quit); monitoring/accessibility-permission/quota-account/update/token/upstream settings are not ported"

requirements-completed: [USAGE-01]

# Coverage metadata (#1602)
coverage:
  - id: D6
    description: "Usage-unavailable detail and official handoff: top-left `Usage unavailable` affordance, local in-place route with reachable Back, exact official URL via the coalesced five-second-bounded launcher, no quota/credential data, exact retryable error"
    requirement: USAGE-01
    verification:
      - kind: unit
        ref: "CodexAtollTests/CapabilityContractTests.swift#testUsageUnavailableCopyMatchesUISpecContract, #testUsageDetailRouteRoundTripIsLocalAndKeepsNotchOpen, #testUsageSurfaceCopyHasNoQuotaOrLoadingPresentation, #testUsageCtaTitleBindsOnlyToTransientOpeningText, #testLocalDestinationsCarryNoQuotaOrAccountData"
        status: pass
      - kind: unit
        ref: "CodexAtollTests/DesktopHandoffLauncherTests.swift#testOfficialUsageURLIsExactlyTheFixedOfficialPage, #testOpenOfficialUsageIssuesExactlyOneURLOpen, #testOpenOfficialUsageCoalescesConcurrentTaps, #testOpenOfficialUsageTimesOutWithInjectedDuration, #testOpenOfficialUsageRetryAfterFailureIsPermitted, #testOpenOfficialUsageURLErrorMapsToLaunchFailed"
        status: pass
      - kind: other
        ref: "source scan: rg for WKWebView|URLSession|SecItemCopyMatching|TokenTrackingManager|ClaudeAPIService in CodexAtoll"
        status: pass
    human_judgment: false
  - id: D7
    description: "Accessible menu entry points and resilient usage layout: 44px native rows, complete localized labels, launcher-dispatched actions, constrained-height scrolling, no quota/loading presentation"
    requirement: USAGE-01
    verification:
      - kind: unit
        ref: "CodexAtollTests/CapabilityContractTests.swift#testMenuButtonAccessibilityLabelIsExact, #testMenuDescriptorsMatchUISpecContract, #testMenuRouteTogglesToMenuAndBack, #testNoBareWorkspaceCallsInSwiftUIViews"
        status: pass
      - kind: other
        ref: "source scan: no bare NSWorkspace call in CodexAtoll/UI/**; forbidden-inventory gate unchanged"
        status: pass
    human_judgment: false
  - id: D8
    description: "Manual runtime smoke: usage opens/reverses in place without changing notch open state, default-browser launch of the official page, keyboard/VoiceOver order, and constrained-height scrolling"
    verification: []
    human_judgment: true
    rationale: "Requires a running macOS window, the installed ChatGPT app / default browser, and visual/accessibility inspection (WindowServer, VoiceOver). VALIDATION.md lists these as manual-only end-of-phase UAT."

# Metrics
duration: 6min
completed: 2026-08-18
status: complete
---

# Phase 01 Plan 04: In-notch Usage Unavailable Handoff and Accessible Menu Summary

**An in-notch `Usage unavailable` affordance and detail with a coalesced, five-second-bounded, retryable official-usage handoff to exactly `https://chatgpt.com/codex/settings/usage`, plus a native 44px local menu — proven by 34 focused XCTest cases and clean identifier-aware source scans**

## Performance

- **Duration:** ~6 min
- **Started:** 2026-08-18T06:13:49Z
- **Completed:** 2026-08-18T06:19:27Z
- **Tasks:** 2 (both `tdd="true"`; Task 1 is the `type="tracer"` slice)
- **Files modified:** 9 (3 created, 6 modified)

## Accomplishments
- The expanded notch's top-left affordance reads exactly `Usage unavailable` (with a decorative `arrow.up.right`, never a percentage, reset time, stale value, progress ring, chart, heatmap, skeleton, or quota-loading indicator). It navigates in place to the new `UsageUnavailableView`, whose Back returns to the companion without closing the notch.
- `UsageUnavailableView` renders Back, the `Usage details unavailable here` heading with a `.jumpOnly` `CapabilityBadge`, the exact UI-SPEC body ("Codex Atoll does not read account credentials or estimate your quota…"), and `Open official Codex usage` on its own 44px row. Content wraps with full VoiceOver text and scrolls at constrained height.
- `DesktopHandoffLauncher` gained the single compile-time `officialUsageURL` constant and `openOfficialUsage()`, reusing the exact coalescing (repeated taps issue one request), five-second production timeout (injectable in tests), and retry contract. The launcher surface renders the exact `Opening official Codex usage…` and browser-fallback error; opening the page is the full data boundary — no fetch, embed, parse, cache, estimate, or retained page/account value.
- The expanded header gained the top-right icon-only menu control announcing `Open Codex Atoll menu` with a 44x44 target. `MenuRow` and `NotchMenuView` ship a four-row ordered menu (`Open ChatGPT`, `Open official Codex usage`, Back, Quit) of native buttons dispatched through the tested launcher; failures stay on the menu with the exact retryable copy. No monitoring, accessibility-permission, quota-account, update, token, or upstream settings were ported.
- `NotchDestination` is now a payload-free three-case enum (`companion` / `usageUnavailable` / `menu`); the route carries no quota, history, or account data. The forbidden-inventory gate and the Task 2 identifier source scan (`WKWebView|URLSession|SecItemCopyMatching|TokenTrackingManager|ClaudeAPIService`) both stay clean, and a new contract test proves SwiftUI view files never call `NSWorkspace` directly.

## Task Commits

Each task was committed atomically (TDD RED then GREEN):

1. **Task 1 RED** - `294f0c7` (test) - failing usage handoff and route contract tests
2. **Task 1 GREEN** - `0140256` (feat) - wire in-notch usage-unavailable handoff
3. **Task 2 RED** - `89c9f81` (test) - failing menu and usage layout contract tests
4. **Task 2 GREEN** - `024d66a` (feat) - add accessible menu entry points and resilient usage layout

**Plan metadata:** (final docs commit for this SUMMARY + STATE/ROADMAP)

## Files Created/Modified
- `CodexAtoll/UI/Views/UsageUnavailableView.swift` - Created: scrollable in-notch detail (Back, heading, `.jumpOnly` badge, body, CTA, exact retryable browser error)
- `CodexAtoll/UI/Views/NotchMenuView.swift` - Created: ordered `MenuItem`/`Action` descriptor set and the four-row scrollable menu dispatched through the launcher
- `CodexAtoll/UI/Components/MenuRow.swift` - Created: native accessible 44px button row with hover affordance
- `CodexAtoll/Core/DesktopHandoffLauncher.swift` - Modified: `WorkspaceOpening.open(_:)`, `SystemWorkspace` URL open, `officialUsageURL`, `openOfficialUsage()` plus the mirrored bounded race
- `CodexAtoll/Core/NotchViewModel.swift` - Modified: `NotchDestination` gains `.usageUnavailable`/`.menu` (CaseIterable), `destination` becomes `private(set)`, adds `openUsageUnavailable()`/`openMenu()`/`goBack()`
- `CodexAtoll/UI/Views/NotchView.swift` - Modified: `NotchStrings` usage/menu copy, closed pill vs expanded header split, usage affordance + menu button, route switch
- `CodexAtoll/Resources/Localizable.xcstrings` - Modified: usage/menu localized copy
- `CodexAtollTests/CapabilityContractTests.swift` - Modified: usage copy/route/no-quota-vocabulary/CTA-binding, menu label/descriptor/route, payload-free destinations, and no-bare-workspace view scan
- `CodexAtollTests/DesktopHandoffLauncherTests.swift` - Modified: `WorkspaceFake` URL seam + exact URL, single-open, error, coalescing, timeout, and retry tests

## Decisions Made
- Kept the official usage handoff as the full data boundary: one compile-time URL, default-browser open only, no page/account value enters Codex Atoll (D-10/D-11).
- Extended the destination enum with two payload-free cases; Back returns to `.companion` without closing the notch (D-09).
- Each surface owns a launcher instance so bounded opening feedback and retryable errors stay on the owning companion/usage/menu surface (Pattern 2).
- Menu import is row-only: only `Open ChatGPT`, `Open official Codex usage`, Back, and Quit ship; the reference's monitoring, accessibility, quota-account, update, token, and upstream settings are excluded (T-04-03).

## Deviations from Plan

### Auto-fixed Issues

None - plan executed exactly as written.

## TDD Gate Compliance
- Task 1 RED: `294f0c7 test(01-04)` - genuine compile failure (missing `officialUsageURL`, `openOfficialUsage()`, `.usageUnavailable`, `openUsageUnavailable()`, `goBack()`, usage strings, `UsageUnavailableView`) -> GREEN: `0140256 feat(01-04)` - 29 focused tests pass.
- Task 2 RED: `89c9f81 test(01-04)` - genuine compile failure (missing `.menu`, `openMenu()`, `openMenu`/`quit` strings, `NotchMenuView`, `allCases`) -> GREEN: `024d66a feat(01-04)` - 34 focused tests pass.
- No REFACTOR commits needed; both GREEN implementations were minimal and complete.

## Issues Encountered
- The Task 1 and Task 2 RED gates both genuinely failed to compile, so the per-task TDD gate is fully compliant.
- No runtime/race or build issues arose during GREEN; the duplicated `runBoundedURLOpen()` mirrors the Plan 03-proven task-group race to avoid the MainActor scheduler starvation previously seen with indirection.

## Tracer Feedback Gate
- Task 1 is the plan's `type="tracer"` slice. Because this run was dispatched as a SEQUENTIAL full-plan executor (per the orchestrator's objective: execute all tasks, create SUMMARY), the tracer's `<verify>` was re-run end-to-end immediately after committing it (29 tests green) before the Task 2 expansion — satisfying the gate's verify-before-expanding intent without emitting an intermediate interactive checkpoint.

## User Setup Required
None - no external service configuration required. Full Xcode (26.6) was verified selected before execution per the task preconditions.

## Next Phase Readiness
- Plan 05 can add the `Privacy & Data` page and menu row (`privacyAndData`) reusing the same route switch, `MenuRow`, localized copy pattern, and the existing identifier-aware source gate (which already avoids banning the human-readable privacy words it must display).
- The `.jumpOnly` capability badge vocabulary is now exercised in production by the usage detail; the verified-data summary/card/heatmap contract remains deferred until an official source supplies individual values and update time (D-10/D-11).
- Manual runtime smoke (usage opens/reverses in place, default-browser launch, VoiceOver/keyboard order, constrained-height scrolling, 44px targets) remains for end-of-phase UAT per VALIDATION.md coverage D8.

---
*Phase: 01-honest-desktop-companion*
*Completed: 2026-08-18*

## Self-Check: PASSED
- All 3 created source files verified present on disk (UsageUnavailableView, NotchMenuView, MenuRow).
- SUMMARY.md present at `.planning/phases/01-honest-desktop-companion/01-04-SUMMARY.md`.
- Task commits verified in git history: `294f0c7` (Task 1 RED), `0140256` (Task 1 GREEN), `89c9f81` (Task 2 RED), `024d66a` (Task 2 GREEN).
- Full focused suite: 34 tests pass; both identifier-aware source scans (forbidden inventory + Task 2 scan) are clean; no bare `NSWorkspace` call exists in SwiftUI view/component files.
