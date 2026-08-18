---
phase: 01-honest-desktop-companion
verified: 2026-08-18T07:05:00Z
status: human_needed
score: 13/13 must-haves verified
behavior_unverified: 0 # All behavior-dependent truths have passing behavioral tests (see Behavioral Spot-Checks)
overrides_applied: 0
human_verification:
  - test: "Launch CodexAtoll.app and inspect the collapsed notch: Codex mark left, neutral eye.slash right, no shortcut/spinner, no automatic expansion; direct click opens the companion card; close returns to the neutral collapsed state."
    expected: "Neutral collapsed shell with complete VoiceOver label 'Codex Atoll. Codex Desktop is currently unobservable.'; no inferred Desktop lifecycle, progress, or credential UI."
    why_human: "Requires a running macOS window and visual/accessibility inspection (WindowServer, VoiceOver). Listed as manual-only UAT in VALIDATION.md (D3, D4, D8)."
  - test: "Click 'Open ChatGPT' with ChatGPT Desktop installed; confirm ChatGPT activates without Atoll claiming a specific task. Temporarily make bundle lookup fail and confirm the Applications fallback copy remains visible."
    expected: "Native activation succeeds; no task-focus claim. On failure the card and exact retryable error stay visible."
    why_human: "External application activation depends on the installed app and WindowServer."
  - test: "Click 'Open official Codex usage'; confirm the default browser opens exactly https://chatgpt.com/codex/settings/usage and Atoll does not request credentials or scrape the page."
    expected: "Default-browser handoff only; no credential prompt; page content stays external."
    why_human: "Browser routing and authenticated official-page content are external."
  - test: "Navigate every Phase 1 control with VoiceOver and keyboard: collapsed pill, Desktop card, usage affordance/detail, menu (Open ChatGPT / Open official Codex usage / Privacy & Data / Back / Quit), Privacy & Data disclosure rows."
    expected: "Literal capability labels announced; full truncated copy read; back/CTA reachable; 44px targets; Reduce Motion respected."
    why_human: "Assistive output and navigation order require macOS accessibility inspection."
  - test: "Engineering decision (REVIEW WR-01): harden DesktopHandoffLauncher.runBounded()/runBoundedURLOpen() so the local Opening state cannot extend beyond five seconds when the underlying Launch Services call is slow or ignores Task cancellation."
    expected: "The timeout is authoritative for the state transition even when the losing child task does not observe cancellation."
    why_human: "Presence checks and current cooperative-fake tests cannot prove the non-cooperative-cancellation path; requires an engineering decision on the fix approach (detached loser, cancellation handler, or first-result continuation)."
---

# Phase 1: Honest Desktop Companion Verification Report

**Phase Goal:** Users can use an honest Desktop companion entry and official usage handoff while understanding Codex Atoll's data boundary.
**Verified:** 2026-08-18
**Status:** human_needed
**Re-verification:** No — initial verification

## Mode Note

ROADMAP.md declares Phase 1 `mode: mvp`. The MVP-mode user-story format guard was checked: `gsd-tools query user-story.validate` returns `valid=false` for the phase goal (it is an outcome statement, not an `As a … / I want to … / so that …` story). The User Flow Coverage table is therefore not produced; verification is performed against the ROADMAP Success Criteria (the roadmap contract) and the per-plan `must_haves`, which are concrete and fully verifiable. If a user-story goal is required, run `/gsd mvp-phase 1`; the Success-Criteria-based verdict below is unaffected.

## Goal Achievement

### Observable Truths

Truths are consolidated from the ROADMAP Success Criteria (SC1–SC4, the roadmap contract) plus plan-specific `must_haves` from 01-01 through 01-05. No plan must-have reduces the roadmap contract; all 4 SCs are verified directly.

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | User can see a source-labelled Codex Desktop entry in the notch that never presents unverified status, history, or approval data. (SC1 / DESK-01) | ✓ VERIFIED | `DesktopCompanionView.cards` is a static array of exactly one card (source `Codex Desktop`, `.currentlyUnobservable`, `eye.slash`); `NotchViewModel` carries only status/destination, no lifecycle/task/credential state. `testDesktopCompanionRendersExactlyOneOrderedCard`, `testCollapsedShellHasNoTaskOrProgressState`, `testCollapsedAccessibilityLabelIsCompleteForVoiceOver` pass. |
| 2 | User can open ChatGPT Desktop from that entry and is told clearly which actions must remain in ChatGPT until an official integration is available. (SC2 / DESK-02, DESK-03) | ✓ VERIFIED | `DesktopHandoffLauncher.openChatGPT()` iterates fixed `["com.openai.codex"]` through `NSWorkspace` (lookup→open→activate). Card body: "Review task details, history, approvals, and actions in ChatGPT until an official integration is available." `testDesktopCardCopyMatchesUISpecContract`, `testActivationSuccessClearsStateWithoutTaskClaim` pass. |
| 3 | User can open the official Codex usage or limits surface without Codex Atoll requesting or reading account credentials. (SC3 / USAGE-01) | ✓ VERIFIED | `officialUsageURL = https://chatgpt.com/codex/settings/usage` is a single compile-time constant; `openOfficialUsage()` only opens it in the default browser; no fetch/parse/cache/estimate. `PhaseBoundaryTests.testExternalTargetInventoryIsExactlyTwoFixedConstants`, `testProductionHasNoKeychainOrOAuthWebAuthOperation`, `testProductionHasNoCookiePrivateDatabaseOrNetworkQuotaPath` pass. |
| 4 | Before enabling any integration, user can review the prompt, tool, result, and session metadata Codex Atoll may process. (SC4 / PRIV-01) | ✓ VERIFIED | `PrivacyDataView` renders six ordered `DisclosureCategory` rows (identity→prompt→tools/results→session/status→processing→retention); prompt/tool/session rows each carry own location+retention. `testDisclosureCategoriesMatchExactOrder`, `testEveryDataRowHasOwnProcessingLocationAndRetention`, `testPrivacyEmptyStateAndCopyMatchUISpecContract` pass. |
| 5 | App launches window-only as a native accessory-panel notch app: no ordinary window, server, database, auth, persistence, or new dependency. | ✓ VERIFIED | `CodexAtollApp` exposes only empty Settings scene; `AppDelegate` sets `.accessory` and creates one `NotchWindowController`/`NotchPanel`. `testStartupLifecycleHasNoInheritedSideEffectServices`, `testNoPhaseOneProductionTypeOwnsPersistentMutableState` pass. |
| 6 | Collapsed notch starts closed, shows bundled Codex mark left and neutral eye.slash right, no persistent shortcut; direct click opens the local companion route; close returns to neutral; no automatic expansion. | ✓ VERIFIED | `NotchView.closedPill` renders mark + eye.slash with complete VoiceOver label; `onTapGesture` → `notchOpen()`; no CGEvent monitor (window frame tracks content). `testFreshModelStartsClosedWithCompanionDestination`, `testDirectOpenThenCloseKeepsLocalRoute` pass. |
| 7 | Expanded companion always renders exactly one ordered Codex Desktop card with one whole-card capability class, complete explanation, CTA; no skeleton, spinner, percentage, history, approval, or task-control surface. | ✓ VERIFIED | `DesktopCompanionView` = one `DesktopCardModel`; `CapabilityClass` vocabulary (available/jumpOnly/currentlyUnobservable) with literal labels + SF Symbols. `testDesktopCardCapabilityIsCurrentlyUnobservable`, `testCapabilityClassVocabularyIsComplete`, `testOpeningStateBindsOnlyToTransientOpeningText` pass. |
| 8 | ChatGPT activation is bounded: repeated taps issue one native request while opening; state clears on success/error/injected timeout with a five-second production bound; failure keeps card visible with exact retryable error. | ✓ VERIFIED | Coalescing guard (`state != .opening`), `productionTimeout = .seconds(5)`, task-group race, all four `HandoffError` cases mapped. Behavioral tests executed and pass: `testDuplicateTapDuringOpeningIssuesOneWorkspaceCall`, `testHangingRequestTimesOutWithInjectedDuration`, `testRetryAfterFailureIsPermitted`, `testProductionTimeoutIsExactlyFiveSeconds`. See WR-01 for a robustness caveat. |
| 9 | Usage: top-left `Usage unavailable` affordance (no quota/numeric/loading UI) opens an in-place scrollable detail with reachable Back; official CTA opens exactly the fixed URL; coalesced/timeout/retry; no remote or account data loaded. | ✓ VERIFIED | `NotchView.usageAffordance` + `UsageUnavailableView` (Back, `.jumpOnly` badge, CTA, exact browser error); payload-free `NotchDestination.usageUnavailable`. Behavioral tests executed and pass: `testOpenOfficialUsageCoalescesConcurrentTaps`, `testOpenOfficialUsageTimesOutWithInjectedDuration`, `testOpenOfficialUsageRetryAfterFailureIsPermitted`, `testAppAndURLOpeningBothSettleWithinInjectedTimeout`, `testUsageSurfaceCopyHasNoQuotaOrLoadingPresentation`. |
| 10 | Accessible menu: Open ChatGPT / Open official Codex usage / Privacy & Data / Back / Quit as native ≥44px rows with complete localized labels, dispatched through the launcher; no bare NSWorkspace in SwiftUI views. | ✓ VERIFIED | `NotchMenuView` ordered `MenuItem`/`Action` descriptors, `MenuRow` 44px; `testMenuDescriptorsMatchUISpecContract`, `testMenuLabelsAreCompleteForAllRows`, `testMenuButtonAccessibilityLabelIsExact`, `testNoBareWorkspaceCallsInSwiftUIViews`, `testControlsMeetMinimumHitTargets` pass. |
| 11 | Privacy & Data always reachable from the expanded menu, no first-launch modal; empty state `No integrations are enabled`; six ordered disclosure rows with per-row location/retention; control obligations (default-off, independent, revocable, clearing); literal credential assurance; held-out backstop recorded. | ✓ VERIFIED | `PrivacyDataView` + `PrivacyStrings` + `DisclosureCategory`; `enableFailureBackstopContract` (backstop). `testFirstLaunchHasNoPrivacyModal`, `testPrivacyMenuRowIsAlwaysReachable`, `testPrivacyControlStatesDefaultOffIndependentRevocableAndClearing`, `testCredentialAssuranceNamesEveryLiteralExclusion`, `testDisclosureSheetFailureBackstopIsRecorded` pass. |
| 12 | Phase-wide boundary: no inherited hook/socket/session-monitor/token/updater identity, no Keychain/OAuth/cookie/private-DB/UI-automation/network/persistence API, exactly two fixed external targets with no interpolation, NSWorkspace confined to the thin launcher. (PRIV-05) | ✓ VERIFIED | `PhaseBoundaryTests` (8 cases) executed and pass; identifier-aware source scans clean (`rg` for HookInstaller|HookSocketServer|TokenTrackingManager|ClaudeSessionMonitor|SUFeedURL|SUPublicEDKey|claudeatoll.engels74.net|SecItemCopyMatching|SecItemAdd|ASWebAuthenticationSession|HTTPCookieStorage|WKWebView|CGEventPost|AXUIElement|URLSession → no matches in `CodexAtoll/`). |
| 13 | Attributed, buildable identity: Apache-2.0 LICENSE + NOTICE pinning snapshot `4e7cf858faa3e013b73150a5e4d41355c4f5be4e` with modifications; bundled Codex mark; renamed app/XCTest targets + shared scheme build from clean. | ✓ VERIFIED | `LICENSE.md` (Apache-2.0), `NOTICE` (pinned snapshot, modification list), `codex-mark.svg` present and used (`Image(.codexMark)`), `xcodebuild -list` shows exactly CodexAtoll + CodexAtollTests + shared scheme; focused suites build and pass under Xcode 26.6. |

**Score:** 13/13 truths verified (0 present-but-behavior-unverified).

### Required Artifacts

| Artifact | Expected | Status | Details |
| -------- | -------- | ------ | ------- |
| `CodexAtoll.xcodeproj/project.pbxproj` | App + XCTest targets, no package/service target | ✓ VERIFIED | `xcodebuild -list`: Targets `CodexAtoll`, `CodexAtollTests`; scheme `CodexAtoll`. |
| `CodexAtoll.xcodeproj/xcshareddata/xcschemes/CodexAtoll.xcscheme` | Shared build-and-test scheme | ✓ VERIFIED | Scheme exists; tests ran through it. |
| `CodexAtoll/App/CodexAtollApp.swift` | `@main` empty-Settings entry | ✓ VERIFIED | Attaches `AppDelegate` via `@NSApplicationDelegateAdaptor`; no ordinary window. |
| `CodexAtoll/App/AppDelegate.swift` | Window-only accessory lifecycle | ✓ VERIFIED | Accessory policy, one `NotchWindowController`, screen-change placement only. |
| `CodexAtoll/Core/NotchViewModel.swift` | Status/destination local route state | ✓ VERIFIED | `NotchStatus`, `NotchDestination` (companion/usageUnavailable/menu/privacyData), no task/credential data. |
| `CodexAtoll/Core/CapabilityClass.swift` | Whole-card capability vocabulary | ✓ VERIFIED | 3 cases with literal localized labels + SF Symbols. |
| `CodexAtoll/Core/DesktopHandoffLauncher.swift` | Bounded native activation + URL handoff | ✓ VERIFIED | `WorkspaceOpening`/`SystemWorkspace`, coalescing, 5s timeout, exact constants. |
| `CodexAtoll/UI/Views/DesktopCompanionView.swift` | Exactly-one honest Desktop card | ✓ VERIFIED | Static one-element `cards`; `.currentlyUnobservable`; CTA; retryable error. |
| `CodexAtoll/UI/Views/UsageUnavailableView.swift` | In-notch usage detail + official handoff | ✓ VERIFIED | Back/heading/jumpOnly/CTA/error; no quota UI. |
| `CodexAtoll/UI/Views/NotchMenuView.swift` + `MenuRow.swift` | Accessible local menu | ✓ VERIFIED | Ordered descriptors; 44px native rows; launcher-dispatched. |
| `CodexAtoll/UI/Views/PrivacyDataView.swift` | Ordered disclosure page + backstop | ✓ VERIFIED | 6 `DisclosureCategory` cases, empty state, control, credentials, backstop. |
| `CodexAtoll/UI/Views/NotchView.swift` + window files | Collapsed/open shell + panel | ✓ VERIFIED | Mark + eye.slash pill, header, route switch, panel/placement. |
| `LICENSE.md`, `NOTICE`, codex-mark.svg | Attribution + asset | ✓ VERIFIED | Apache-2.0; NOTICE pins snapshot + modifications; SVG template asset. |
| `CodexAtollTests/CapabilityContractTests.swift` | Shell/card/usage/privacy contracts | ✓ VERIFIED | 35 test methods, all pass. |
| `CodexAtollTests/DesktopHandoffLauncherTests.swift` | Handoff determinism | ✓ VERIFIED | 16 test methods, all pass (coalescing/timeout/retry/URL). |
| `CodexAtollTests/PhaseBoundaryTests.swift` | Phase-wide boundary proofs | ✓ VERIFIED | 8 test methods, all pass. |

### Key Link Verification

| From | To | Via | Status |
| ---- | --- | --- | ------ |
| `project.pbxproj` | `CodexAtollApp.swift` | target membership + `@main` | ✓ WIRED |
| shared scheme | `project.pbxproj` | app/test target references | ✓ WIRED (`xcodebuild -list`) |
| `AppDelegate.swift` | `NotchWindowController.swift` | `applicationDidFinishLaunching` | ✓ WIRED |
| `NotchViewController.swift` | `NotchView.swift` | `PassThroughHostingView(rootView:)` | ✓ WIRED |
| `NotchView.swift` | `NotchViewModel.swift` | `notchOpen/notchClose`, route switch | ✓ WIRED |
| `NotchView.swift` | `DesktopCompanionView.swift` | `.companion` route | ✓ WIRED |
| `DesktopCompanionView.swift` | `DesktopHandoffLauncher.swift` | `openChatGPT()` | ✓ WIRED |
| `DesktopHandoffLauncher.swift` | `NSWorkspace` | `urlForApplication/openApplication/activate/open` | ✓ WIRED |
| `NotchView.swift` | `UsageUnavailableView.swift` | `.usageUnavailable` route | ✓ WIRED |
| `UsageUnavailableView.swift` | `DesktopHandoffLauncher.swift` | `openOfficialUsage()` | ✓ WIRED |
| `DesktopHandoffLauncher.swift` | `https://chatgpt.com/codex/settings/usage` | `officialUsageURL` constant | ✓ WIRED |
| `NotchMenuView.swift` | `PrivacyDataView.swift` | `.privacyData` route via `onOpenPrivacy` | ✓ WIRED |
| `PrivacyDataView.swift` | `Localizable.xcstrings` | `String(localized:)` keys | ✓ WIRED (52 keys present) |
| `PhaseBoundaryTests.swift` | production source | source-boundary assertions | ✓ WIRED (passing) |

### Data-Flow Trace (Level 4)

Phase 1 is intentionally data-free by design (no quota, task, history, or account data crosses the boundary). Rendered values trace to real localized string resources or compile-time constants:

| Artifact | Data Variable | Source | Produces Real Data | Status |
| -------- | ------------- | ------ | ------------------ | ------ |
| Desktop card | source/body/action/error | `NotchStrings` (Localizable.xcstrings) | Yes (localized) | ✓ FLOWING |
| Capability badge | label/systemImage | `CapabilityClass` localized | Yes | ✓ FLOWING |
| Usage detail | heading/body/CTA/error | `NotchStrings` (localized) | Yes | ✓ FLOWING |
| Privacy rows | title/body/location/retention | `DisclosureCategory` localized | Yes | ✓ FLOWING |
| External targets | bundle set / usage URL | compile-time constants | Yes (fixed) | ✓ FLOWING |

No rendered value terminates in a mock/hardcoded empty literal; the static nature is the honest boundary (D-10/D-11: no fabricated quota or task data).

### Behavioral Spot-Checks

All 59 test cases executed under Xcode 26.6 (`xcodebuild test … -derivedDataPath .build`). The two behavior-dependent truths (coalescing + five-second-bound timeout + retry for both ChatGPT and official-usage handoffs) are exercised by passing named tests — not symbol-presence evidence.

| Behavior | Command | Result | Status |
| -------- | ------- | ------ | ------ |
| Exactly-one Desktop card + copy + no task UI | `CapabilityContractTests` (35 cases) | 35/35 pass | ✓ PASS |
| Desktop/usage handoff coalescing, injected timeout, retry, exact URL, 5s production bound | `DesktopHandoffLauncherTests` (16 cases) | 16/16 pass | ✓ PASS |
| Phase-wide boundary: external-target inventory, NSWorkspace confinement, no credential/private/automation/persistence APIs | `PhaseBoundaryTests` (8 cases) | 8/8 pass | ✓ PASS |
| Forbidden-inventory source scan | `rg … HookInstaller\|…\|AXUIElement\|URLSession` | no matches (exit 1) | ✓ PASS |
| Identity scan | `rg ClaudeAtoll\|ProgressView\|@AppStorage\|UserDefaults` | no matches | ✓ PASS |
| Project/scheme inventory | `xcodebuild -list` | exactly CodexAtoll + CodexAtollTests + scheme | ✓ PASS |
| Localization catalog | keys for Desktop/usage/privacy/credential copy | all present (52 keys) | ✓ PASS |

### Probe Execution

Step 7c: SKIPPED — no `scripts/*/tests/probe-*.sh` probes exist and the plans declare none; all phase verification uses inline `xcodebuild`/`rg` commands, which were re-executed directly above.

### Requirements Coverage

All six Phase 1 requirement IDs are claimed by exactly the intended plans and every one is satisfied by implementation evidence. No orphaned requirements (REQUIREMENTS.md maps only these six to Phase 1, and all appear in ≥1 plan).

| Requirement | Source Plans | Description | Status | Evidence |
| ----------- | ------------ | ----------- | ------ | -------- |
| DESK-01 | 01-01, 01-02, 01-03 | Source-labelled Desktop entry, no unverified status/history/approval | ✓ SATISFIED | One ordered `Codex Desktop` / `.currentlyUnobservable` card; neutral collapsed state; tests. |
| DESK-02 | 01-03 | Activate ChatGPT Desktop from notch | ✓ SATISFIED | `DesktopHandoffLauncher.openChatGPT()` via `com.openai.codex`; coalesced/5s/retry; tests. |
| DESK-03 | 01-03 | Explain unavailable capability + native fallback | ✓ SATISFIED | Exact body "…must be completed in ChatGPT until an official integration…"; retryable error; tests. |
| USAGE-01 | 01-04 | Open official usage surface without reading credentials | ✓ SATISFIED | `officialUsageURL` exact constant; default-browser open only; no credential/quota data; tests. |
| PRIV-01 | 01-05 | Review prompt/tool/result/session metadata before enabling | ✓ SATISFIED | `PrivacyDataView` six ordered disclosure rows with location/retention; empty state; tests. |
| PRIV-05 | 01-05 | Never asked for OAuth token/session cookie/Keychain credential | ✓ SATISFIED | Literal assurance copy; no credential API in production; `PhaseBoundaryTests`. |

### Anti-Patterns Found

No debt markers (`TBD/FIXME/XXX/TODO/HACK/PLACEHOLDER`), stub patterns, empty implementations, or console-only code in production source. The phase code review (01-REVIEW.md, 0 critical / 3 warning / 4 info) found robustness issues, none of which contradict a claimed must-have:

| File | Issue | Severity | Impact |
| ---- | ----- | -------- | ------ |
| `DesktopHandoffLauncher.swift:149-171,197-217` | WR-01: `withTaskGroup` implicitly awaits the losing child, so a slow/non-cancellable Launch Services call can keep `.opening` beyond five seconds despite the timeout. Tests pass only with cancellation-cooperative fakes. | ⚠️ Warning | Robustness of the "Opening ends within five seconds" promise; not a boundary violation; no data-loss/injection risk. Routed to human/engineering follow-up. |
| `NotchViewModel.swift:68-83` | WR-02: `makeStatusStream()` onTermination nil-outs the newly created continuation on a second call; latent (single call site today). | ⚠️ Warning | Latent; documented public contract invites the second call. |
| `AppDelegate.swift:55-67` | WR-03: same-display resolution/arrangement changes skip re-placement (display-ID-only guard). | ⚠️ Warning | Pill can stay off-center until display changes. |
| `NotchView.swift:259-292`, `AppDelegate.swift:22`, tests source-path helpers | IN-01..IN-04: 44px controls overflow the ~36-38px header row; source-scan helpers `XCTSkip` on path changes; `LSUIElement` not in Info.plist; `MainActor.assumeIsolated` coupling. | ℹ️ Info | Cosmetic/latent; no blocker. |

### Human Verification Required

The following items need human/engineering confirmation (also listed in frontmatter):

1. **Notch runtime smoke (visual)** — launch app; verify collapsed pill (Codex mark left, eye.slash right), click-to-expand, local close, no auto-expansion, Reduce Motion, keyboard focus.
2. **Real ChatGPT activation** — `Open ChatGPT` activates the installed ChatGPT Desktop without a task claim; broken-lookup fallback copy stays visible.
3. **Real official-usage browser open** — default browser opens exactly `https://chatgpt.com/codex/settings/usage`; no credential prompt.
4. **VoiceOver / keyboard / accessibility** — full literal capability labels, truncated body copy, menu label, back/CTA reachable across all four routes.
5. **WR-01 engineering decision** — harden the launcher so a non-cooperative (hung) Launch Services call cannot extend `.opening` past the five-second bound (REVIEW recommends settling state from the first result, leaving the loser detached, plus a cancellation-ignoring test). WR-02/WR-03 and IN-01..IN-04 also merit follow-up.

### Gaps Summary

No must-have truth failed; no artifact is missing, stub, or unwired; no key link is broken; no blocker anti-pattern exists. The phase goal — honest source-labelled Desktop entry, bounded ChatGPT activation, official usage handoff without credential reads, and a reviewable privacy data boundary — is achieved in the codebase and behaviorally proven by 59 passing XCTest cases plus clean identifier-aware source scans.

The phase is not marked `passed` because the manual runtime/accessibility UAT items (visual notch behavior, real ChatGPT/browser activation, VoiceOver order) require a human at the end-of-phase checkpoint, and REVIEW WR-01 warrants an engineering decision on hardening the five-second opening bound.

---

_Verified: 2026-08-18_
_Verifier: Claude (gsd-verifier)_
