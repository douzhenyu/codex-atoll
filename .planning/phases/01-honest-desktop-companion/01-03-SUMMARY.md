---
phase: 01-honest-desktop-companion
plan: 03
subsystem: desktop
tags: [swiftui, appkit, xcode, xctest, macos, apache-2.0]

# Dependency graph
requires:
  - phase: 01-02
    provides: "Native collapsed/open notch shell, single local companion route, MainActor contract test gate"
provides:
  - "Complete honest Desktop card: exactly one Codex Desktop / Currently unobservable card with the exact explanation and bounded native ChatGPT activation"
  - "CapabilityClass + CapabilityBadge: literal whole-card capability vocabulary with SF Symbols"
  - "DesktopHandoffLauncher + WorkspaceOpening/SystemWorkspace: coalesced, five-second-bounded native handoff that never implies or operates a Desktop task"
affects: [01-04, 01-05]

# Actuals (#2632) — same chars/4 scale as the plan's `estimate` (34000).
actuals:
  tokens: 7600
  tasks: 2
  commits: 4

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Whole-card capability: CapabilityClass raw-value enum with localized label and SF Symbol, rendered by CapabilityBadge (icon hidden from VoiceOver, literal label always announced)"
    - "Bounded native handoff: thin WorkspaceOpening/Activatable boundary, fixed ordered bundle set, task-group race of the native request against a five-second duration"
    - "Coalescing: MainActor openChatGPT() guard returns while .opening so repeated taps issue exactly one workspace call"

key-files:
  created:
    - CodexAtoll/Core/CapabilityClass.swift
    - CodexAtoll/Core/DesktopHandoffLauncher.swift
    - CodexAtoll/UI/Components/CapabilityBadge.swift
    - CodexAtoll/UI/Views/DesktopCompanionView.swift
    - CodexAtollTests/DesktopHandoffLauncherTests.swift
  modified:
    - CodexAtoll/Resources/Localizable.xcstrings
    - CodexAtoll/UI/Views/NotchView.swift
    - CodexAtollTests/CapabilityContractTests.swift

key-decisions:
  - "One capability class per whole card: the Desktop card is currentlyUnobservable (eye.slash); available/jumpOnly exist in the vocabulary but are reserved for later verified/owned sessions"
  - "The launcher owns an ordered compile-time identifier set containing only the verified com.openai.codex; no aliases, deep links, or UI automation are guessed"
  - "The handoff races the native request against a five-second production timeout (injectable in tests), coalesces while .opening, and maps lookup/open/activation/timeout to explicit local results"
  - "WorkspaceOpening exposes only lookup/open/activate; SystemWorkspace is the AppKit implementation and the test fake is the only other conformer"

requirements-completed: [DESK-01, DESK-02, DESK-03]

# Coverage metadata (#1602)
coverage:
  - id: D4
    description: "Complete honest Desktop card: exactly one ordered Codex Desktop / Currently unobservable card with exact body, Open ChatGPT CTA, retryable error, and no task-control surface"
    requirement: [DESK-01, DESK-03]
    verification:
      - kind: unit
        ref: "CodexAtollTests/CapabilityContractTests.swift#testDesktopCompanionRendersExactlyOneOrderedCard, #testDesktopCardCapabilityIsCurrentlyUnobservable, #testDesktopCardCopyMatchesUISpecContract, #testCapabilityClassVocabularyIsComplete, #testOpeningStateBindsOnlyToTransientOpeningText"
        status: pass
    human_judgment: false
  - id: D5
    description: "Bounded native ChatGPT activation: fixed bundle lookup, async open, activation result, in-flight coalescing, five-second timeout, and retry — with no task state/action route"
    requirement: DESK-02
    verification:
      - kind: unit
        ref: "CodexAtollTests/DesktopHandoffLauncherTests.swift (identifier set, lookup/open/activation mapping, duplicate-tap coalescing, injected timeout, retry, production timeout)"
        status: pass
      - kind: other
        ref: "source scan: rg for CGEventPost|AXUIElement|WKWebView|URLSession|SecItemCopyMatching|ASWebAuthenticationSession|HTTPCookieStorage in CodexAtoll"
        status: pass
    human_judgment: false

# Metrics
duration: 10min
completed: 2026-08-18
status: complete
---

# Phase 01 Plan 03: Complete Honest Desktop Card and Bounded ChatGPT Activation Summary

**One fixed Codex Desktop / Currently unobservable card whose only external action is a coalesced, five-second-bounded native ChatGPT activation through a thin Launch Services boundary — proven by 19 focused XCTest cases and clean identifier-aware source scans**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-08-18T05:57:05Z
- **Completed:** 2026-08-18T06:06:34Z
- **Tasks:** 2 (both `tdd="true"`)
- **Files modified:** 8 (5 created, 3 modified)

## Accomplishments
- Replaced the shell's static companion content with exactly one ordered `DesktopCompanionView` card: source `Codex Desktop`, the complete icon-plus-literal `Currently unobservable` `CapabilityBadge`, the exact UI-SPEC explanation, and a native `Open ChatGPT` CTA on its own 44px row. No loading skeleton, task spinner, percentage, history, approval, prompt, pause, or timeline exists.
- Added `CapabilityClass` (available / jumpOnly / currentlyUnobservable) with localized labels and SF Symbols, and `CapabilityBadge` that hides the decorative glyph from VoiceOver and always announces the literal label.
- Added the thin `WorkspaceOpening`/`Activatable` boundary with a real `SystemWorkspace` AppKit implementation. The launcher iterates the ordered compile-time set `["com.openai.codex"]`, opens the first registered match asynchronously, requires activation success, and maps lookup nil / launch error / activation false / timeout to explicit local results. Success clears to idle and makes no task-focus claim.
- Coalesced and bounded the handoff: a second tap while `.opening` issues no second workspace call, and the native request races a configurable duration whose production default is exactly five seconds. Every completion path returns to an actionable local state; the card and explanation stay visible on failure with the exact retryable Applications copy.
- Extended the forbidden source gate with `WKWebView`, `URLSession`, `SecItemCopyMatching`, `ASWebAuthenticationSession`, and `HTTPCookieStorage` — the app ships with no UI automation, credential/private-store reader, embedded browser, or network client.

## Task Commits

Each task was committed atomically (TDD RED then GREEN):

1. **Task 1 RED** - `2ea3c5e` (test) - failing capability card and handoff launcher contract tests
2. **Task 1 GREEN** - `dcc6fe8` (feat) - wire complete Desktop card to bounded ChatGPT activation
3. **Task 2 RED** - `4146006` (test) - failing coalescing and timeout handoff tests
4. **Task 2 GREEN** - `c347cc2` (feat) - bound, coalesce, and prove the Desktop handoff

**Plan metadata:** (final docs commit for this SUMMARY + STATE/ROADMAP)

## Files Created/Modified
- `CodexAtoll/Core/CapabilityClass.swift` - Created: literal whole-card capability vocabulary (labels + SF Symbols)
- `CodexAtoll/Core/DesktopHandoffLauncher.swift` - Created: `WorkspaceOpening`/`Activatable`/`SystemWorkspace`, `HandoffState`, `HandoffError`, and the coalesced, five-second-bounded `DesktopHandoffLauncher`
- `CodexAtoll/UI/Components/CapabilityBadge.swift` - Created: accessible icon-plus-literal capability badge renderer
- `CodexAtoll/UI/Views/DesktopCompanionView.swift` - Created: the single fixed `DesktopCardModel` and `DesktopCompanionView` (source, badge, body, CTA, transient opening text, retryable error)
- `CodexAtoll/UI/Views/NotchView.swift` - Modified: companion route now hosts `DesktopCompanionView` in a vertical ScrollView; added localized CTA/opening/error strings to `NotchStrings`
- `CodexAtoll/Resources/Localizable.xcstrings` - Modified: added `Available`, `Jump only`, `Open ChatGPT`, `Opening ChatGPT…`, and the Applications fallback copy
- `CodexAtollTests/CapabilityContractTests.swift` - Modified: one-card cardinality, copy/vocabulary, opening-state binding, and extended forbidden-inventory gate
- `CodexAtollTests/DesktopHandoffLauncherTests.swift` - Created: identifier set, result mapping, coalescing, injected timeout, retry, and production-timeout tests against the thin workspace fake

## Decisions Made
- Kept one capability class per card and rendered the Desktop card as `.currentlyUnobservable`; `available` and `jumpOnly` are vocabulary only, reserved for later verified/owned sessions.
- Owned the verified bundle identifier as an ordered compile-time constant in the launcher (`com.openai.codex`); no alias guessing or deep links.
- Made the handoff MainActor-isolated, coalescing while `.opening`, and raced the native request against an injectable duration (production `Duration.seconds(5)`) so tests never sleep five seconds.
- Chose the direct `withTaskGroup` race with the app target's default MainActor isolation (see deviations) because an indirect pre-created-Task race was starved by the MainActor scheduler.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Indirect task-group race starved the MainActor scheduler**
- **Found during:** Task 2 (GREEN phase)
- **Issue:** The first timeout implementation created two unstructured `Task { @MainActor in }` instances and then awaited their `.value` from `withTaskGroup` children. It compiled but every mapping test took the full five-second production timeout (the open result was consumed only after the timeout fired), and the injected 100ms timeout never fired at all.
- **Fix:** Replaced the indirection with a direct `withTaskGroup` where the children perform the work themselves, relying on the app target's `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` default. Explicit `@MainActor` annotations on the child closures triggered a region-based isolation checker limitation ("pattern that the region-based isolation checker does not understand how to check"), so they were dropped in favor of the target-wide default.
- **Files modified:** `CodexAtoll/Core/DesktopHandoffLauncher.swift`
- **Verification:** Full suite green; the injected-100ms timeout test passes in ~0.1s and all mapping tests pass in milliseconds.
- **Committed in:** `c347cc2` (Task 2 GREEN commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Internal implementation correction only; the plan's file list, contracts, and verify commands are all honoured.

## TDD Gate Compliance
- Task 1 RED: `2ea3c5e test(01-03)` - genuine compile failure (types intentionally absent) -> GREEN: `dcc6fe8 feat(01-03)` - 15 focused tests pass.
- Task 2 RED: `4146006 test(01-03)` - genuine compile failure (missing `timeout:` parameter and `productionTimeout`) -> GREEN: `c347cc2 feat(01-03)` - 19 focused tests pass.
- No REFACTOR commits needed; both GREEN implementations were minimal and complete.

## Issues Encountered
- The Task 1 and Task 2 RED gates both genuinely failed to compile, so the per-task TDD gate is fully compliant.
- The runtime race issue described in Deviations was the only non-RED problem and was resolved within Task 2.

## User Setup Required
None - no external service configuration required. Full Xcode (26.6) was verified selected before execution per the task preconditions.

## Next Phase Readiness
- Plan 04 can add the usage-unavailable detail and official usage handoff reusing the same thin `WorkspaceOpening`-style boundary and the localized copy pattern already established here.
- Plan 05 can add the Privacy & Data page; the identifier-aware source gate already avoids banning the human-readable privacy words it must display.
- Manual runtime smoke (complete card order, native activation/error, keyboard focus, VoiceOver full content, overflow scroll, neutral collapsed state, and no task-progress animation) remains for end-of-phase UAT per VALIDATION.md.

---
*Phase: 01-honest-desktop-companion*
*Completed: 2026-08-18*

## Self-Check: PASSED
- All 5 created source/test files verified present on disk (CapabilityClass, DesktopHandoffLauncher, CapabilityBadge, DesktopCompanionView, DesktopHandoffLauncherTests).
- SUMMARY.md present at `.planning/phases/01-honest-desktop-companion/01-03-SUMMARY.md`.
- Task commits verified in git history: `2ea3c5e` (Task 1 RED), `dcc6fe8` (Task 1 GREEN), `4146006` (Task 2 RED), `c347cc2` (Task 2 GREEN).
- Full focused suite: 19 tests pass; source scans for inherited services and automation/private-reader/network identifiers are clean.
