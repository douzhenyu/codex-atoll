---
phase: 01-honest-desktop-companion
plan: 05
subsystem: desktop
tags: [swiftui, appkit, xcode, xctest, macos, apache-2.0, privacy]

# Dependency graph
requires:
  - phase: 01-04
    provides: "In-notch usage-unavailable handoff, accessible menu (NotchMenuView/MenuRow), localized copy pattern, identifier-aware source gate"
provides:
  - "Always-accessible Privacy & Data page with the exact pre-enable empty state and complete ordered data-boundary template"
  - "Ordered DisclosureCategory rows (identity → prompt → tools/results → session/status → processing → retention), each with own processing-location and retention statement"
  - "PhaseBoundaryTests production inventory and forbidden-path coverage proving the fork left no credential, private-Desktop, automation, or inherited update/hook path"
  - "Held-out disclosure-sheet failure backstop recorded and registered as a testable production contract"
affects: [02-trusted-cli-monitoring, 04-atoll-owned-sessions, 06-public-release-delivery]

# Actuals (#2632) — same chars/4 scale as the plan's `estimate` (34000).
actuals:
  tokens: 13882   # chars/4 over the realized diff (55527 chars / 4)
  tasks: 2
  commits: 4

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Static disclosure template: enum DisclosureCategory (CaseIterable/Hashable/Sendable) resolving localized title/body/location/retention per row; combined VoiceOver label joins all four"
    - "Held-out backstop: a named production contract (PrivacyDataView.enableFailureBackstopContract) records a future UI contract without instantiating enablement"
    - "Identifier-aware phase-boundary proof: PhaseBoundaryTests scans executable API identifiers/class names, never human-readable privacy copy (e.g. OAuth token, session cookie, Keychain credential)"

key-files:
  created:
    - CodexAtoll/UI/Views/PrivacyDataView.swift
    - CodexAtollTests/PhaseBoundaryTests.swift
  modified:
    - CodexAtoll/Core/NotchViewModel.swift
    - CodexAtoll/Resources/Localizable.xcstrings
    - CodexAtoll/UI/Views/NotchMenuView.swift
    - CodexAtoll/UI/Views/NotchView.swift
    - CodexAtollTests/CapabilityContractTests.swift
    - CodexAtollTests/DesktopHandoffLauncherTests.swift

key-decisions:
  - "The Privacy & Data page owns its copy in a dedicated PrivacyStrings enum inside PrivacyDataView.swift; DisclosureCategory cases resolve their own localized title/body/location/retention via String(localized:)"
  - "The six disclosure rows are all DisclosureCategory cases (including the umbrella processing-location and retention rows); the prompt/tool/session data rows must each carry non-empty location and retention so no merged generic row is possible"
  - "The held-out enablement backstop is a named production contract (enableFailureBackstopContract) rendered in the page's Before-enabling section and registered by a test, satisfying the UI-SPEC backstop without a live enable action"
  - "PhaseBoundaryTests assert API identifiers and class/route names only (SecItemCopyMatching, ASWebAuthenticationSession, HTTPCookieStorage, AXUIElement, …) so the human-readable assurance copy the page must display stays legal"

patterns-established:
  - "Always-accessible route: NotchDestination gained .privacyData (payload-free) and the menu gained the Privacy & Data row between usage and back; navigation is local, no launch modal"
  - "Disclosure-row model: each data category is a distinct, ordered, localized row that states processing location and retention adjacency"
  - "Source-boundary scan: app sources enumerated from the test file's repo root; forbidden identifier scan covers inherited services, credential/private-data, automation, network, and persistence"

requirements-completed: [PRIV-01, PRIV-05]

# Coverage metadata (#1602)
coverage:
  - id: D1
    description: "Always-accessible Privacy & Data page: payload-free .privacyData route, always-visible menu row, no first-launch modal, exact empty-state copy, complete ordered disclosure template, D-14 control obligations, and literal D-16 credential/private-data exclusions"
    requirement: PRIV-01
    verification:
      - kind: unit
        ref: "CodexAtollTests/CapabilityContractTests.swift#testPrivacyRouteRoundTripIsLocalAndKeepsNotchOpen, #testFirstLaunchHasNoPrivacyModal, #testPrivacyMenuRowIsAlwaysReachable, #testDisclosureCategoriesMatchExactOrder, #testEveryDataRowHasOwnProcessingLocationAndRetention, #testPrivacyEmptyStateAndCopyMatchUISpecContract, #testPrivacyControlStatesDefaultOffIndependentRevocableAndClearing, #testCredentialAssuranceNamesEveryLiteralExclusion"
        status: pass
      - kind: unit
        ref: "CodexAtollTests/CapabilityContractTests.swift#testLocalizationCatalogContainsPrivacyContract, #testPrivacyTemplateDoesNotClaimConsentOrEnabledIntegration, #testPrivacyCategoryAccessibilityLabelsRetainCompleteContent, #testPrivacyDisclosureContentRemainsComplete"
        status: pass
    human_judgment: false
  - id: D2
    description: "Held-out disclosure-sheet failure backstop recorded as a named production contract and registered by a test (no enablement instantiated in Phase 1)"
    requirement: PRIV-01
    verification:
      - kind: unit
        ref: "CodexAtollTests/CapabilityContractTests.swift#testDisclosureSheetFailureBackstopIsRecorded"
        status: pass
    human_judgment: false
  - id: D3
    description: "Phase-wide privacy and capability boundary: exactly two fixed external targets with no interpolation/mutable configuration, NSWorkspace confined to the thin launcher, clean startup lifecycle, and no Keychain/OAuth/cookie/private-DB/network/automation/persistence API identifier in production source"
    requirement: PRIV-05
    verification:
      - kind: unit
        ref: "CodexAtollTests/PhaseBoundaryTests.swift (8 cases: external-target inventory, no interpolation, NSWorkspace confinement, startup lifecycle, Keychain/OAuth, cookie/private-DB/network, UI automation, persistent-state owner)"
        status: pass
      - kind: other
        ref: "source scan: ! rg -n 'HookInstaller|HookSocketServer|TokenTrackingManager|ClaudeSessionMonitor|SUFeedURL|SUPublicEDKey|claudeatoll\\.engels74\\.net|SecItemCopyMatching|SecItemAdd|ASWebAuthenticationSession|HTTPCookieStorage|WKWebView|CGEventPost|AXUIElement' CodexAtoll"
        status: pass
      - kind: other
        ref: "xcodebuild test -project CodexAtoll.xcodeproj -scheme CodexAtoll -destination 'platform=macOS' (58 tests) && xcodebuild build -project CodexAtoll.xcodeproj -scheme CodexAtoll -configuration Debug -derivedDataPath .build"
        status: pass
    human_judgment: false
  - id: D4
    description: "Manual runtime smoke: all three routes reachable, exact errors, keyboard/VoiceOver order, scrolling, neutral collapsed state, Reduce Motion, and no first-launch credential/accessibility/update/integration prompt"
    verification: []
    human_judgment: true
    rationale: "Requires a running macOS window and visual/accessibility inspection (WindowServer, VoiceOver). VALIDATION.md lists these as manual-only end-of-phase UAT. The automated launch smoke (process alive, clean stderr/stdout, clean terminate, window-only lifecycle, fresh state starts closed at companion) was performed."

# Metrics
duration: 12min
completed: 2026-08-18
status: complete
---

# Phase 01 Plan 05: Privacy & Data Boundary and Phase-Wide Capability Proof Summary

**An always-accessible Privacy & Data page with the exact pre-enable empty state and ordered six-row data-boundary disclosure, plus PhaseBoundaryTests proving the fork left no inherited, credential, private-Desktop, automation, or mutable-external-target path — 58 tests green and a clean window-only launch smoke**

## Performance

- **Duration:** ~12 min
- **Started:** 2026-08-18T06:26:33Z
- **Completed:** 2026-08-18T06:38:32Z
- **Tasks:** 2 (both `tdd="true"`; Task 1 is the `type="tracer"` slice)
- **Files modified:** 8 (2 created, 6 modified)

## Accomplishments
- The expanded notch's menu always contains `Privacy & Data` (between usage and Back), which navigates in place to the new `PrivacyDataView` via the payload-free `.privacyData` route. No launch path presents a privacy modal; a fresh model still starts closed at the companion route (D-12/D-15).
- With zero integrations enabled the page shows the exact empty state `No integrations are enabled` plus its exact body and the complete pre-enable template. It renders six ordered `DisclosureCategory` rows (integration identity → prompt text → tool calls and results → session/status metadata → processing location → retention); each prompt/tool/session data row states its own processing-location and retention so a merged generic data row is impossible (D-13).
- The page states that integrations start off, are authorized independently, are revocable, and are paired with clearing of Codex Atoll-owned local data, and it offers no live enable toggle (D-14). The credential assurance literally names Codex OAuth token, session cookie, and Keychain credential, with separate exclusions for ChatGPT/Codex Desktop private databases and UI-scraped task data (D-16). All copy is localized and each row/section exposes a complete combined VoiceOver label.
- The UI-SPEC held-out backstop is recorded as a named production contract `PrivacyDataView.enableFailureBackstopContract` (a failed future enable action keeps the sheet open, names the integration, explains the failure, and leaves consent off), rendered in the page's Before-enabling section and registered by a test — without instantiating enablement.
- `PhaseBoundaryTests` proves the exactly-two fixed external targets (`com.openai.codex` activation and the fixed official usage HTTPS URL) with no user/task/account interpolation or mutable configuration, NSWorkspace confined to the thin `DesktopHandoffLauncher` boundary, a clean window-only startup lifecycle, and no Keychain/OAuth/cookie/private-DB/network/automation/persistence API identifier anywhere in production source. The immediate identifier-aware source scan (including the new `SecItemAdd` term) exits 0, the full scheme passes 58 tests, and the Debug build plus launch smoke are clean.

## Task Commits

Each task was committed atomically (TDD RED then GREEN):

1. **Task 1 RED** - `1909206` (test) - failing Privacy & Data contract tests (route, menu, order, location/retention, copy, catalog, VoiceOver)
2. **Task 1 GREEN** - `626529f` (feat) - deliver the always-accessible Privacy & Data contract
3. **Task 2 RED** - `3a9442d` (test) - failing phase-boundary and privacy backstop tests (PhaseBoundaryTests + extended contract tests)
4. **Task 2 GREEN** - `326406a` (feat) - prove the phase-wide privacy and capability boundary

**Plan metadata:** (final docs commit for this SUMMARY + STATE/ROADMAP/REQUIREMENTS)

## Files Created/Modified
- `CodexAtoll/UI/Views/PrivacyDataView.swift` - Created: `PrivacyStrings`, `DisclosureCategory` (six ordered cases resolving localized title/body/location/retention), and the scrollable `PrivacyDataView` (empty state, disclosure cards, control, credentials, held-out backstop; 44px back target; combined VoiceOver labels)
- `CodexAtollTests/PhaseBoundaryTests.swift` - Created: production-inventory and forbidden-path boundary proofs (external-target cardinality/equality/no-interpolation, NSWorkspace confinement, startup lifecycle, credential/private-data, automation, persistence)
- `CodexAtoll/Core/NotchViewModel.swift` - Modified: `NotchDestination` gains `.privacyData`; `openPrivacyData()` added
- `CodexAtoll/Resources/Localizable.xcstrings` - Modified: ~46 privacy keys (empty state, category rows, control, credentials, backstop)
- `CodexAtoll/UI/Views/NotchMenuView.swift` - Modified: `Action.privacyData`, `onOpenPrivacy`, and the always-visible `Privacy & Data` row
- `CodexAtoll/UI/Views/NotchView.swift` - Modified: route switch hosts `PrivacyDataView`; menu wired to `openPrivacyData()`
- `CodexAtollTests/CapabilityContractTests.swift` - Modified: privacy contract, menu-descriptor (5 rows), destination-set, localization-catalog, VoiceOver-label, backstop, 44px hit-target, ellipsis/accessibility, and disclosure-completeness tests
- `CodexAtollTests/DesktopHandoffLauncherTests.swift` - Modified: cross-path test proving both app and URL handoffs settle within the injected bound

## Decisions Made
- Kept the Privacy & Data copy in a dedicated `PrivacyStrings` enum inside `PrivacyDataView.swift` (the plan's file boundary) instead of growing `NotchStrings`; `DisclosureCategory` resolves its own localized content.
- Modeled the six disclosure rows as one `DisclosureCategory` enum so the exact order is testable; the prompt/tool/session rows are exposed as `dataCategories` and each carries non-empty location + retention.
- Recorded the held-out enablement backstop as a named production contract that the page renders and the test registers, satisfying the UI-SPEC `verification: backstop` without a live enable action.
- Phase-boundary assertions scan API identifiers and class/route names only, keeping the human-readable OAuth/session-cookie/Keychain assurance copy legal.

## Deviations from Plan
None - plan executed exactly as written. The plan file list was honoured and no scope was added; the two TDD-flow test corrections below are test-authoring fixes, not plan deviations.

## Issues Encountered
- **Task 1 GREEN (test assertion vs. copy):** the RED assertion `testPrivacyControlStatesDefaultOffIndependentRevocableAndClearing` checked for the substring "revoke", while the (accurate, D-14) copy says "revocable at any time". The assertion was corrected to "revocable" so the D-14 obligation is still fully asserted.
- **Task 2 GREEN (test authoring):** the new cross-path timeout test initially failed to compile (`async` test method lacked `throws`) and then settled on `.applicationUnavailable` because the `WorkspaceFake` had no `lookupURL`. Both were fixed in the GREEN phase (marked the method `throws`, set a lookup URL so the open path hangs and times out). The final test proves both handoffs settle within the injected bound.
- **TDD RED structure for Task 2:** because Plans 01-04 and Task 1 already satisfied every Task 2 behavior, the genuine RED driver was the plan's held-out disclosure-sheet backstop symbol (`PrivacyDataView.enableFailureBackstopContract`), which Task 2 GREEN introduced — the compile failure was real and the GREEN resolved it. All Task 2 production-inventory proofs then passed against the clean source.

## Tracer Feedback Gate
Task 1 is the plan's `type="tracer"` slice. Because this run was dispatched as a SEQUENTIAL full-plan executor (per the orchestrator's objective: execute all tasks, create SUMMARY), the tracer's `<verify>` was re-run end-to-end immediately after committing it (29 CapabilityContractTests green) before the Task 2 expansion — satisfying the gate's verify-before-expanding intent without emitting an intermediate interactive checkpoint.

## TDD Gate Compliance
- Task 1 RED: `1909206 test(01-05)` - genuine compile failure (missing `privacyData`, `openPrivacyData()`, `DisclosureCategory`, `PrivacyStrings`, `PrivacyDataView`) -> GREEN: `626529f feat(01-05)` - 29 focused contract tests pass.
- Task 2 RED: `3a9442d test(01-05)` - genuine compile failure (missing `PrivacyDataView.enableFailureBackstopContract`) -> GREEN: `326406a feat(01-05)` - full suite of 58 tests passes including all 8 PhaseBoundaryTests.
- No REFACTOR commits needed; both GREEN implementations were minimal and complete.

## User Setup Required
None - no external service configuration required. Full Xcode (26.6) was verified selected before execution per the task preconditions.

## Next Phase Readiness
- The `PrivacyStrings`/`DisclosureCategory` vocabulary and the always-accessible route are the exact data-category language Phase 2's live per-integration consent sheet must reuse.
- The held-out backstop contract (`enableFailureBackstopContract`) is the named contract the future enablement sheet must honor; `PhaseBoundaryTests` is the durable regression gate for any later integration work.
- Manual runtime smoke (visual Privacy & Data layout, keyboard/VoiceOver order, scrolling, Reduce Motion, and the three routes) remains for end-of-phase UAT per VALIDATION.md coverage D4.

---
*Phase: 01-honest-desktop-companion*
*Completed: 2026-08-18*

## Self-Check: PASSED
- All created files verified present: `CodexAtoll/UI/Views/PrivacyDataView.swift`, `CodexAtollTests/PhaseBoundaryTests.swift`.
- SUMMARY.md present at `.planning/phases/01-honest-desktop-companion/01-05-SUMMARY.md`.
- Task commits verified in git history: `1909206` (Task 1 RED), `626529f` (Task 1 GREEN), `3a9442d` (Task 2 RED), `326406a` (Task 2 GREEN).
- Full suite: 58 tests pass (CapabilityContractTests 34, DesktopHandoffLauncherTests 16, PhaseBoundaryTests 8); Task 2 source scan clean; Debug build + launch smoke clean.
