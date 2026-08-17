# Phase 1: Honest Desktop Companion - Research

**Researched:** 2026-08-17  
**Domain:** Native macOS notch handoff, capability-honest Desktop UX, and privacy disclosure  
**Confidence:** MEDIUM

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Notch Entry and Expansion
- **D-01:** In the collapsed notch, show the Codex icon on the left and a compact state symbol or animation on the right. Do not add a persistent shortcut button.
- **D-02:** A loading animation may represent only an officially observable or Codex Atoll-owned session. The Phase 1 Desktop entry uses a neutral unavailable/handoff state, never an inferred running state.
- **D-03:** Keep the notch collapsed by default. Only blocking interactions such as approval, choice, or additional-input requests may trigger automatic expansion; those live interactions belong to later observable-session phases.
- **D-04:** An automatic expansion retracts after 5 seconds without interaction. After interaction begins, retract 300 ms after both pointer and keyboard focus leave.

### Capability Presentation
- **D-05:** Use a text label plus icon for each capability class: `Available`, `Jump only`, or `Currently unobservable`. Color is supplemental and never the sole signal.
- **D-06:** Apply one capability class to an entire card. Split mixed capabilities into separate cards so a card never combines available controls with jump-only or unobservable behavior.
- **D-07:** The Phase 1 Desktop card is `Currently unobservable`: state plainly that Codex Atoll cannot obtain current Codex runtime information, provide `Open ChatGPT`, and never show a loading skeleton or spinner.

### Usage Summary and Detail
- **D-08:** Reserve the expanded notch's top-left area for usage. When an authoritative source is available, the compact summary prioritizes remaining percentage plus reset time.
- **D-09:** Clicking the summary switches to an in-notch detail view with a back action. The intended verified-data view contains quota cards and a 30-day daily heatmap.
- **D-10:** Every usage value must show its official source and last-updated time. A retained last-known value must be marked stale after refresh failure.
- **D-11:** Phase 1 has no supported source for authoritative account-wide quota or historical heatmap data. It therefore shows an explicit unavailable state and opens the official Codex usage/limits surface; it must not infer, scrape, or fabricate values. The live summary and heatmap activate only when a later official source satisfies the same contract.

### Privacy Disclosure
- **D-12:** Do not block first launch with a generic privacy modal. Immediately before enabling each integration, show an integration-specific disclosure.
- **D-13:** The disclosure lists prompt text, tool calls and results, session/status metadata, where each category is processed, and how long it is retained.
- **D-14:** Integrations are off by default, authorized independently, revocable at any time, and paired with a way to clear Codex Atoll-owned local data.
- **D-15:** Keep an always-accessible `Privacy & Data` page.
- **D-16:** Never request or read Codex OAuth tokens, session cookies, Keychain credentials, ChatGPT/Codex Desktop private databases, or UI-scraped task data.

### the agent's Discretion
- Exact privacy-page layout, iconography, and concise copy may be chosen during UI design, provided D-12 through D-16 remain explicit and testable.

### Deferred Ideas (OUT OF SCOPE)
- Live loading states, automatic expansion for approval/input, in-notch commands, choices, pause, and approval belong to Phases 2–4, where Codex Atoll has an official observable or owned session.
- Authoritative account-wide remaining quota and historical heatmaps remain deferred until OpenAI exposes a supported data source; Phase 1 implements only the truthful unavailable/handoff state.
</user_constraints>

## Project Constraints (from AGENTS.md)

- Start from Claude Atoll, preserve Apache-2.0 attribution/notices, and retain the SwiftUI/AppKit macOS architecture. [VERIFIED: AGENTS.md:3-26]
- Support both Codex CLI and Codex Desktop in v1, but prefer official or stable local interfaces and never rely on fragile UI scripting for direct approvals. [VERIFIED: AGENTS.md:14-24]
- Capability availability and fallbacks must be explicit; Phase 1 must honour the Desktop boundary rather than claiming parity with later CLI/App Server work. [VERIFIED: AGENTS.md:20-25]
- Do not make direct implementation edits outside an active GSD workflow. [VERIFIED: AGENTS.md:39-47]

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DESK-01 | `User can see a source-labelled Codex Desktop entry that never claims unverified task status, history, or approval capability.` [VERIFIED: .planning/REQUIREMENTS.md:31] | Static `Codex Desktop` / `Currently unobservable` card; no transport, session monitor, loading state, or action other than app activation. |
| DESK-02 | `User can activate ChatGPT Desktop from the notch to continue or review Desktop work.` [VERIFIED: .planning/REQUIREMENTS.md:32] | Launch Services lookup plus async `NSWorkspace.openApplication`; explicit success/failure result. |
| DESK-03 | `User can see why a Desktop capability is unavailable and that the action must be completed in ChatGPT until an official integration exists.` [VERIFIED: .planning/REQUIREMENTS.md:33] | Fixed explanatory copy, whole-card capability badge, and no disabled faux controls. |
| USAGE-01 | `User can open the official Codex usage or limits surface from Codex Atoll without Codex Atoll reading account credentials.` [VERIFIED: .planning/REQUIREMENTS.md:51] | Open the verified official dashboard URL in the default browser; do not request, persist, fetch, or parse credentials/data. |
| PRIV-01 | `User can review what prompt, tool, result, and session metadata Codex Atoll may process before enabling monitoring.` [VERIFIED: .planning/REQUIREMENTS.md:56] | Always-reachable local Privacy & Data view plus a preview of the future per-integration confirmation contract. |
| PRIV-05 | `User is never asked to give Codex Atoll their Codex OAuth token, session cookie, or Keychain credential for monitoring or usage display.` [VERIFIED: .planning/REQUIREMENTS.md:60] | Delete/exclude Claude OAuth/token-tracking paths, no credential UI, and test source/route boundary. |
</phase_requirements>

## Summary

Phase 1 is a small native shell, not a Desktop monitor. Bootstrap the Apache-2.0 Claude Atoll fork only far enough to preserve its app/window/notch/menu mechanics, then replace the Claude session view with one fixed Codex Desktop handoff card, one usage-unavailable detail, and a local Privacy & Data page. The Desktop card must never receive a session state, transcript, approval, or progress field; its only external action is to bring the current ChatGPT Desktop application forward. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/App/ClaudeAtollApp.swift:10-20; /Users/dou/claude-atoll/ClaudeAtoll/UI/Views/NotchView.swift:428-455] [CITED: https://help.openai.com/en/articles/20001276/]

Use standard AppKit launch services rather than a deep link or accessibility automation. The current locally installed ChatGPT desktop app declares `CFBundleIdentifier` as `"com.openai.codex"`; this is a compatibility input, not a permanent public protocol, so keep it in one launcher constant and test it during every supported-release build. [VERIFIED: /Applications/ChatGPT.app/Contents/Info.plist:195-196 — `"com.openai.codex"`] Apple documents both bundle-ID application lookup and asynchronous application launch with a completion error, which provides the correct failure path: keep the card visible and show the approved actionable error. [CITED: https://developer.apple.com/documentation/appkit/nsworkspace/urlforapplication%28withbundleidentifier%3A%29] [CITED: https://developer.apple.com/documentation/appkit/nsworkspace/openapplication%28at%3Aconfiguration%3Acompletionhandler%3A)]

The official Codex pricing page’s `Codex usage dashboard` target currently resolves to `https://chatgpt.com/codex/settings/usage`. Phase 1 should open that page in the default browser and intentionally stop there: it must not load the URL in-app, query an unofficial endpoint, read a token, or render percentages, resets, cards, or a heatmap. [CITED: https://chatgpt.com/codex/pricing/] [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:153-158]

**Primary recommendation:** Make the first tracer slice a buildable renamed notch app with a fixed, source-labelled Desktop card and two tested `NSWorkspace` handoffs; defer every real task/progress/usage integration to its owning later phase. [VERIFIED: .planning/ROADMAP.md:24-34] [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:103-115]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Collapsed/expanded notch and fixed companion pages | Native macOS client | — | SwiftUI renders the local, source-labelled contract; there is no server data path in this phase. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/UI/Window/NotchWindowController.swift:15-96] |
| ChatGPT activation | Native macOS client | Launch Services | The client asks macOS to locate/activate an app; it does not observe or operate a Desktop task. [CITED: https://developer.apple.com/documentation/appkit/nsworkspace/urlforapplication%28withbundleidentifier%3A%29] |
| Official usage handoff | Native macOS client | Default browser / official ChatGPT site | The client launches a URL and owns no account values. [CITED: https://developer.apple.com/documentation/appkit/nsworkspace] [CITED: https://chatgpt.com/codex/pricing/] |
| Privacy disclosure | Native macOS client | — | The policy copy is local and reviewable before any integration exists. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-CONTEXT.md:43-48] |
| Future verified task-progress indicator | Later Codex CLI/App Server adapter | Native macOS client | Only an officially observable or Atoll-owned event may drive it; it is deliberately dormant in Phase 1. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:103-115]

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Swift 6 + SwiftUI + AppKit | Swift 6; inherited macOS 15.6 baseline | App lifecycle, notch surface, navigation, and accessibility | The reference project already uses `@NSApplicationDelegateAdaptor`, an accessory app, custom `NSPanel`, and SwiftUI content; no web runtime is needed. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/App/ClaudeAtollApp.swift:10-20; /Users/dou/claude-atoll/ClaudeAtoll/App/AppDelegate.swift:46-61; /Users/dou/claude-atoll/ClaudeAtoll/UI/Window/NotchWindowController.swift:35-76] |
| AppKit `NSWorkspace` / `NSRunningApplication` | OS SDK | Locate, launch, and activate ChatGPT; open official URL | It has native lookup and asynchronous launch APIs with explicit errors; no shell execution, deep link, or UI automation is necessary. [CITED: https://developer.apple.com/documentation/appkit/nsworkspace] [CITED: https://developer.apple.com/documentation/appkit/nsrunningapplication/activate%28options%3A%29] |
| XCTest | OS SDK | Unit tests for routing, state contracts, and launch result mapping | Xcode test targets use `XCTestCase`; async test methods are supported for Swift-concurrency code. [CITED: https://developer.apple.com/documentation/xctest/xctestcase] |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Sparkle, swift-markdown, OcclusionKit, swift-subprocess | Existing reference pins; no version change in Phase 1 | Existing project capabilities | Preserve only what the copied shell actually compiles against. Do not start Sparkle with Claude Atoll’s feed/key; update/release work is Phase 6. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll.xcodeproj/project.pbxproj:30-42; /Users/dou/claude-atoll/ClaudeAtoll/Info.plist:20-26] |
| SwiftUI `accessibilityReduceMotion` | OS SDK | Gate the deferred activity animation | When later trusted running states exist, replace looping activity with the static UI-SPEC fallback when the system setting is true. [CITED: https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion] [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:139-144] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `NSWorkspace` activation | Accessibility clicks, process injection, or a guessed task deep link | Reject: each would claim a task-level integration not established by the phase and could operate the wrong Desktop UI. [VERIFIED: .planning/PROJECT.md:13-26] |
| Static usage-unavailable view | OAuth/Keychain/private HTTP quota integration | Reject: violates PRIV-05 and conflicts with the locked no-credentials boundary. [VERIFIED: .planning/REQUIREMENTS.md:51-60] |
| Local privacy page | Launch-time consent modal | Reject: D-12 locks a non-blocking first launch; future consent belongs immediately before the integration being enabled. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-CONTEXT.md:43-48] |

**Installation:** No external package installation is introduced in this phase. Retain only the resolved dependencies copied from the Apache-2.0 reference project, then remove unused target memberships rather than adding a package. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll.xcodeproj/project.pbxproj:30-42]

## Package Legitimacy Audit

No package is newly installed by Phase 1, so a package-legitimacy gate is not applicable. The execution plan should preserve or remove already-resolved reference dependencies based on actual target membership, not add dependencies for navigation, browser launch, state, privacy copy, or tests. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll.xcodeproj/project.pbxproj:30-42]

## Architecture Patterns

### System Architecture Diagram

```text
User click / keyboard focus
          |
          v
  NotchWindowController + NotchViewModel
          |
          +--> Desktop companion card -------------------+
          |       source: Codex Desktop                  |
          |       capability: Currently unobservable     |
          |                    |                          |
          |                    v                          |
          |       DesktopHandoffLauncher                  |
          |       | resolve registered ChatGPT app        |
          |       | launch / activate via NSWorkspace     |
          |       +--> success: return to macOS app       |
          |       +--> failure: retain card + error       |
          |                                               |
          +--> Usage unavailable -> NSWorkspace URL open -+--> official browser page
          |
          +--> Privacy & Data -> local static disclosure

No Codex Desktop task store, credential store, hook, socket, App Server, or network response enters this Phase 1 data flow.
```

The only process boundary is user-initiated launch/URL opening. This shape is intentionally smaller than the reference monitor, whose launch path immediately schedules `HookInstaller.installIfNeeded()` and later stops `HookSocketServer`; neither path is allowed in Phase 1. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/App/AppDelegate.swift:46-61; /Users/dou/claude-atoll/ClaudeAtoll/App/AppDelegate.swift:81-95] [VERIFIED: .planning/phases/01-honest-desktop-companion/01-CONTEXT.md:49-62]

### Recommended Project Structure

```text
CodexAtoll/
├── App/
│   ├── CodexAtollApp.swift             # adapted SwiftUI/AppKit entry point
│   ├── AppDelegate.swift               # window lifecycle only; no hooks/updater startup
│   └── WindowManager.swift              # inherited screen/notch lifecycle
├── Core/
│   ├── NotchViewModel.swift             # local routes and open/close state
│   ├── DesktopHandoffLauncher.swift     # one native launcher + result mapping
│   └── NotchGeometry.swift              # inherited geometry
├── UI/
│   ├── Window/                           # inherited custom panel/hosting shell
│   └── Views/
│       ├── NotchView.swift               # collapsed and expanded source-labelled shell
│       ├── DesktopCompanionView.swift     # fixed unobservable Desktop card
│       ├── UsageUnavailableView.swift    # local detail + official handoff
│       └── PrivacyDataView.swift          # fixed local disclosure
└── CodexAtollTests/
    ├── CapabilityContractTests.swift
    └── DesktopHandoffLauncherTests.swift
```

The proposed names are plan-level structure, not existing target paths. They preserve the reference’s App/Core/UI split while avoiding a provider adapter or session model before any provider data exists. [ASSUMED]

### Pattern 1: Explicit local route state

**What:** Replace the reference `instances/menu/chat` content switch with exactly the three Phase 1 local destinations: companion, usage unavailable, and privacy/menu. The capability string is a fixed value owned by the Desktop companion view, not a response from ChatGPT. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/Core/NotchViewModel.swift:30-45; /Users/dou/claude-atoll/ClaudeAtoll/UI/Views/NotchView.swift:428-455] [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:121-125]

**When to use:** For all Phase 1 navigation. Add source-qualified session state only when Phases 2 or 4 introduce a documented event stream. [VERIFIED: .planning/ROADMAP.md:15-20]

**Verified contract values:** `"Available"`, `"Jump only"`, and `"Currently unobservable"`; the Phase 1 Desktop card must use the last value. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:121-125]

### Pattern 2: Result-bearing external handoff

**What:** Map each user-initiated `NSWorkspace` request to a tiny local result state: idle, opening (bounded to five seconds), or error. On error, leave the originating card/detail visible and show the exact approved fallback text; never route through automation. [CITED: https://developer.apple.com/documentation/appkit/nsworkspace/openapplication%28at%3Aconfiguration%3Acompletionhandler%3A)] [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:146-158; .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:202]

**When to use:** `Open ChatGPT` and `Open official Codex usage` only. A success means the OS accepted the launch request, not that a particular task, account page, or Codex mode is selected. [CITED: https://developer.apple.com/documentation/appkit/nsrunningapplication/activate%28options%3A%29]

```swift
// Source: Apple NSWorkspace documentation
let workspace = NSWorkspace.shared
guard let applicationURL = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
    throw DesktopHandoffError.applicationUnavailable
}
let application = try await workspace.openApplication(
    at: applicationURL,
    configuration: .init(),
)
guard application.activate() else {
    throw DesktopHandoffError.activationFailed
}
```

This is a recommended code shape; `bundleIdentifier`, `DesktopHandoffError`, and the result enum are Phase 1 implementation names, not existing repo values. [ASSUMED]

### Pattern 3: Fixed privacy disclosure with future enablement template

**What:** Render local, static sections for prompt text; tool calls/results; session/status metadata; processing location; retention; revocation/deletion; and explicit exclusions. Render a non-actionable preview of the future confirmation sheet rather than creating a disabled integration switch. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-CONTEXT.md:43-48] [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:160-166]

**When to use:** Always in Phase 1; use the same data-category vocabulary in Phase 2’s live hook consent sheet. [VERIFIED: .planning/ROADMAP.md:15-20]

### Bootstrap Sequence

1. Record the source snapshot (`engels74/claude-atoll` local commit `4e7cf858faa3e013b73150a5e4d41355c4f5be4e`) and copy the Apache-2.0 license plus required attribution before modifying code. Apache 2.0 requires recipients to receive the license and modified files to carry notices; retain any applicable notices. [VERIFIED: /Users/dou/claude-atoll/LICENSE.md:1-4; /Users/dou/claude-atoll/LICENSE.md:47-71]
2. Import only the buildable native shell and its direct dependencies: app entry, window manager/controller/hosting view, geometry/screen helpers, and the minimal menu-row/layout code. The reference’s synchronized Xcode group automatically includes source files, so immediately verify target membership and remove unused files rather than staging a full monitoring implementation. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll.xcodeproj/project.pbxproj:43-55; /Users/dou/claude-atoll/ClaudeAtoll.xcodeproj/project.pbxproj:83-108]
3. Rename bundle/product/logging identity and replace the reference’s Sparkle URL/public key before the first executable run. The original Info.plist contains `"https://claudeatoll.engels74.net/appcast.xml"` and its `SUPublicEDKey`; leaving them live would make Codex Atoll check another product’s update feed. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/Info.plist:20-26]
4. Remove automatic hook install, hook socket lifecycle, accessibility-warning flow, token tracking, credentials, and all Claude-specific monitor/menu content before wiring the Phase 1 views. The reference starts hook installation at app launch and its token cache has an OAuth path through its own and the CLI Keychains. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/App/AppDelegate.swift:46-61; /Users/dou/claude-atoll/ClaudeAtoll/Core/TokenTrackingManager+CredentialCache.swift:17-68]
5. Add the fixed Desktop/usage/privacy surfaces and handoff launcher; then add a native XCTest target and run a physical-mac smoke check once Xcode is installed. [CITED: https://developer.apple.com/documentation/xctest/defining-test-cases-and-test-methods]

### Anti-Patterns to Avoid

- **Copying `ClaudeSessionMonitor` into the Phase 1 path:** it would make the static Desktop card depend on non-existent Codex data and blur the live-monitor boundary. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/UI/Views/NotchView.swift:107-160]
- **Copying the activity spinner or token rings:** the reference header derives them from processing/permission/token-tracking properties, whereas the Phase 1 contract prohibits a Desktop spinner, progress ring, or numeric usage placeholder. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/UI/Views/NotchView.swift:141-160; .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:94-101]
- **Leaving automatic hooks enabled:** the inherited lifecycle calls `HookInstaller.installIfNeeded()` before the user has reviewed a Codex integration disclosure. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/App/AppDelegate.swift:46-61] [VERIFIED: .planning/phases/01-honest-desktop-companion/01-CONTEXT.md:43-48]
- **Retaining inherited OAuth/Keychain code as dormant code:** it is both a privacy hazard and contrary to the promised credential boundary; delete it rather than merely hiding its controls. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/Core/TokenTrackingManager+CredentialCache.swift:17-68] [VERIFIED: .planning/REQUIREMENTS.md:60]
- **Using the reference’s global event monitor/click reposting without need:** Phase 1 has no verified auto-expansion event and no reason to request accessibility-related monitoring. Use native panel hit testing/click handling for the local surface; reconsider focus-management only when a future blocking request exists. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/Core/NotchViewModel.swift:296-400] [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:132-144]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| App discovery/activation | `/Applications` path guessing, shell `open`, process injection | `NSWorkspace.urlForApplication(withBundleIdentifier:)`, `openApplication`, and `NSRunningApplication.activate()` | Launch Services can report nil/error/failure and handles registered app locations. [CITED: https://developer.apple.com/documentation/appkit/nsworkspace/urlforapplication%28withbundleidentifier%3A%29] [CITED: https://developer.apple.com/documentation/appkit/nsworkspace/openapplication%28at%3Aconfiguration%3Acompletionhandler%3A)] |
| Official usage viewer | Embedded webview, page scraper, rate-limit estimator | Default-browser URL handoff | Phase 1 does not own the authenticated account context and must not fabricate values. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-CONTEXT.md:30-41] |
| Notch window/geometry | New menu-bar/popover shell | Existing `NotchWindowController`, pass-through hosting view, and geometry | The reference already supplies the required custom non-activating panel and hit-test boundary. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/UI/Window/NotchWindowController.swift:35-96; /Users/dou/claude-atoll/ClaudeAtoll/UI/Window/NotchViewController.swift:9-75] |
| Privacy consent engine | Generic consent framework | Static local page now; native confirmation sheet only with the first actual integration | There is no Phase 1 integration to approve, so a mutable consent state would be dead functionality. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-CONTEXT.md:43-48] |

**Key insight:** The honest result is deliberately small: native app activation and URL opening are the only integration operations required, and both already exist in AppKit. [CITED: https://developer.apple.com/documentation/appkit/nsworkspace]

## Runtime State Inventory

| Category | Items Found | Action Required |
|----------|-------------|-----------------|
| Stored data | None in the target repository: it contains planning artifacts only and no app database, sessions, or user defaults schema. [VERIFIED: target root inspection on 2026-08-17] | No data migration. Do not import Claude session/token caches. |
| Live service config | None in the target repository. The reference app’s old Sparkle feed is configuration that must not be carried into Codex Atoll. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/Info.plist:20-26] | Replace/remove source feed/key during bootstrap; Phase 6 supplies Codex Atoll’s signed feed. |
| OS-registered state | No Codex Atoll registration exists yet. The locally installed ChatGPT bundle identifies as `"com.openai.codex"`, but it is a lookup target, not state to edit. [VERIFIED: /Applications/ChatGPT.app/Contents/Info.plist:195-196] | Resolve it at runtime; show the specified error if absent. |
| Secrets/env vars | None in the target. The reference contains OAuth/Keychain paths and is not a permissible migration source. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/Core/TokenTrackingManager+CredentialCache.swift:17-68] | Exclude/delete credential code; no secret migration. |
| Build artifacts / installed packages | None in the target. Reference has an Xcode project with resolved package references but target has no copied app or build output yet. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll.xcodeproj/project.pbxproj:83-108] | Bootstrap fresh from the selected source snapshot; do not copy DerivedData/build directories. |

## Common Pitfalls

### Pitfall 1: Desktop presence is mistaken for task state
**What goes wrong:** A spinner, status glyph, task list, or approval button appears because ChatGPT is running or because the app handoff succeeded. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:94-101]

**Why it happens:** The reference UI derives its header from a live Claude monitor, but Phase 1 has no verified Desktop event source. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/UI/Views/NotchView.swift:141-160]

**How to avoid:** Make the Desktop card compile against fixed copy/capability only; leave the approved `ProgressView` contract behind a future source-qualified state. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:103-115]

**Warning signs:** Any Phase 1 Desktop code imports a session monitor, has a `running` branch, or renders a `ProgressView`. [ASSUMED]

### Pitfall 2: Inherited update, hooks, and credentials leak across the fork
**What goes wrong:** First launch installs Claude hooks, starts a socket, checks the Claude Sparkle feed, or opens Keychain-related flow. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/App/AppDelegate.swift:46-95; /Users/dou/claude-atoll/ClaudeAtoll/Info.plist:20-26; /Users/dou/claude-atoll/ClaudeAtoll/Core/TokenTrackingManager+CredentialCache.swift:17-68]

**Why it happens:** The reference app starts those services during its app lifecycle and token UI owns OAuth caching. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/App/AppDelegate.swift:46-61; /Users/dou/claude-atoll/ClaudeAtoll/UI/Views/NotchView.swift:107-132]

**How to avoid:** Treat identity/side-effect removal as the first bootstrap task and source-scan the target for `Claude`, `Hook`, `TokenTracking`, `Keychain`, `OAuth`, and the old Sparkle domain before build. [ASSUMED]

**Warning signs:** A clean first run reaches an updater, accessibility alert, hook installer, socket listener, or credential prompt. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/App/AppDelegate.swift:46-95]

### Pitfall 3: Handoff success is reported before macOS confirms it
**What goes wrong:** The UI claims ChatGPT or the usage dashboard is open even though no compatible app/default browser exists. [CITED: https://developer.apple.com/documentation/appkit/nsworkspace/openapplication%28at%3Aconfiguration%3Acompletionhandler%3A)]

**Why it happens:** The one-shot `open(URL) -> Bool` path does not expose an asynchronous error object; application activation may return false. [CITED: https://developer.apple.com/documentation/appkit/nsworkspace] [CITED: https://developer.apple.com/documentation/appkit/nsrunningapplication/activate%28options%3A%29]

**How to avoid:** Use the asynchronous APIs, bind their completion result to transient local feedback for at most five seconds, and preserve the original destination with its exact fallback message. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:146-158; .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:202]

**Warning signs:** A failure results in a blank panel, an endlessly spinning CTA, browser automation, or a claimed task focus. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:146-158]

### Pitfall 4: Accessibility is implemented only visually
**What goes wrong:** The unavailable symbol and color carry meaning but VoiceOver users cannot learn the source/capability; later animation ignores Reduce Motion. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:197-202]

**How to avoid:** Give the collapsed state a full label, use literal text plus icon on capability badges, keep CTAs as native buttons, and read `accessibilityReduceMotion` before future looping animation. [CITED: https://developer.apple.com/documentation/swiftui/view-accessibility] [CITED: https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion]

## Code Examples

Verified patterns from official sources:

### Launch a registered application and surface failure

```swift
// Source: Apple NSWorkspace docs
func openDesktopApp(bundleIdentifier: String) async -> Result<Void, DesktopHandoffError> {
    let workspace = NSWorkspace.shared
    guard let url = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
        return .failure(.applicationUnavailable)
    }

    do {
        let app = try await workspace.openApplication(at: url, configuration: .init())
        return app.activate() ? .success(()) : .failure(.activationFailed)
    } catch {
        return .failure(.launchFailed)
    }
}
```

The planner should keep this behavior behind one concrete launcher type and inject only a thin `NSWorkspace` wrapper in tests; a multi-provider service layer is unnecessary in Phase 1. [CITED: https://developer.apple.com/documentation/appkit/nsworkspace/urlforapplication%28withbundleidentifier%3A%29] [CITED: https://developer.apple.com/documentation/appkit/nsworkspace/openapplication%28at%3Aconfiguration%3Acompletionhandler%3A)]

### Respect Reduce Motion for the deferred animation

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

var activitySymbol: some View {
    Image(systemName: "arrow.triangle.2.circlepath")
        .symbolEffect(reduceMotion ? .none : .rotate, options: .repeating)
}
```

This is a later-phase-only pattern; do not instantiate it for the unobservable Desktop card. [CITED: https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion] [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:139-144]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Separate Codex app / prior ChatGPT desktop app | New ChatGPT desktop app combines Chat, Work, and Codex | OpenAI’s current Help article, updated 2026-08-17 | Use the current ChatGPT desktop product as the handoff target, but do not assume its local bundle ID or task API is a stable public contract. [CITED: https://help.openai.com/en/articles/20001276/] |
| Local OAuth/private usage endpoint | Official browser handoff for all Phase 1 usage | Locked Phase 1 scope | Keeps account credentials and plan-specific data outside Codex Atoll. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-CONTEXT.md:30-41] |

**Deprecated/outdated:**
- The copied Claude Atoll token/Keychain approach is prohibited for Codex Atoll Phase 1, because the new project commits never to request or read the corresponding credentials. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/Core/TokenTrackingManager+CredentialCache.swift:17-68] [VERIFIED: .planning/REQUIREMENTS.md:60]
- Claude Atoll’s startup hook installer and socket server are not Phase 1 functionality; their future Codex equivalents require Phase 2 consent and authenticated-bridge work. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/App/AppDelegate.swift:46-95] [VERIFIED: .planning/ROADMAP.md:15-20]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Proposed Phase 1 target file names and the exact local route enum names are implementation choices, not inherited code. | Recommended Project Structure / Patterns | Low — planner can adjust filenames while preserving responsibility boundaries. |
| A2 | A thin test-only `NSWorkspace` wrapper is sufficient to simulate launcher results without adding a generic integration abstraction. | Code Examples | Low — if AppKit cannot be isolated cleanly, use a protocol at that one boundary only. |
| A3 | Source scanning for inherited terms is an adequate pre-build safety check alongside runtime smoke tests. | Common Pitfalls | Medium — it detects copied paths but cannot prove an external side effect was impossible. |

## Open Questions

1. **What long-lived Codex Atoll bundle identifier and Team ID will public distribution use?**
   - What we know: the reference identifier is `com.engels74.ClaudeAtoll`, and its Info.plist includes its own Sparkle feed/key. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll.xcodeproj/project.pbxproj:304-305; /Users/dou/claude-atoll/ClaudeAtoll/Info.plist:20-26]
   - What's unclear: the new public identity has not been allocated. [ASSUMED]
   - Recommendation: set a development-safe Codex Atoll identifier while bootstrapping, keep Sparkle disabled, and make Developer ID/Sparkle identity a Phase 6 decision gate. [VERIFIED: .planning/ROADMAP.md:15-20]

2. **How should a renamed, side-by-side ChatGPT desktop bundle be detected after OpenAI changes its identifier?**
   - What we know: the current local app declares `"com.openai.codex"`, while Apple’s lookup API returns nil if no matching bundle identifier is registered. [VERIFIED: /Applications/ChatGPT.app/Contents/Info.plist:195-196] [CITED: https://developer.apple.com/documentation/appkit/nsworkspace/urlforapplication%28withbundleidentifier%3A%29]
   - What's unclear: OpenAI has not published a task-level desktop handoff/compatibility identifier in the sources reviewed. [ASSUMED]
   - Recommendation: centralize the identifier, add a manual compatibility probe, and show the required Applications fallback when it does not resolve. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:146-151]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Swift toolchain | Source type checking / package resolution | ✓ | 6.2 | — [VERIFIED: local `swift --version` on 2026-08-17] |
| Codex CLI | Later compatibility work; not required to run Phase 1 UI | ✓ | 0.147.0 | Phase 1 must not depend on it. [VERIFIED: local `codex --version` on 2026-08-17] |
| ChatGPT desktop app | Manual `Open ChatGPT` smoke test | ✓ | bundle `com.openai.codex` | Required runtime fallback is the in-card Applications instruction. [VERIFIED: /Applications/ChatGPT.app/Contents/Info.plist:195-196] |
| Full Xcode | Build/run and XCTest | ✗ | Command Line Tools selected; `xcodebuild` reports no active Xcode | Install/select full Xcode before execution. [VERIFIED: local `xcodebuild -version` on 2026-08-17] |
| SwiftFormat / SwiftLint | Reference formatting/lint parity | ✗ | — | Use Xcode build/test initially; install only if the copied CI requires them. [VERIFIED: local command availability on 2026-08-17; /Users/dou/claude-atoll/.swiftformat:1-57] |

**Missing dependencies with no fallback:**
- Full Xcode is needed to prove a built macOS app and XCTest target; Command Line Tools alone cannot run `xcodebuild`. [VERIFIED: local `xcodebuild -version` on 2026-08-17]

**Missing dependencies with fallback:**
- SwiftFormat/SwiftLint are not Phase 1 execution blockers; preserve their configuration and add them when CI/public-release work is introduced. [VERIFIED: /Users/dou/claude-atoll/.swiftformat:1-57]

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | XCTest in a new native Xcode test target. [CITED: https://developer.apple.com/documentation/xctest/defining-test-cases-and-test-methods] |
| Config file | none — Xcode target configuration is Wave 0. [VERIFIED: target root inspection on 2026-08-17] |
| Quick run command | `xcodebuild test -project CodexAtoll.xcodeproj -scheme CodexAtoll -destination 'platform=macOS'` [ASSUMED] |
| Full suite command | Same command until an explicit UI-test target becomes necessary. [ASSUMED] |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DESK-01 | Desktop presentation has fixed source/capability and exposes no status/history/approval action route. | unit + manual visual | `xcodebuild test -project CodexAtoll.xcodeproj -scheme CodexAtoll -destination 'platform=macOS'` [ASSUMED] | ❌ Wave 0 |
| DESK-02 | Missing app, launch error, activation false, and success map to visible handoff outcomes. | unit + manual app smoke | same [ASSUMED] | ❌ Wave 0 |
| DESK-03 | Unavailable card contains explanation and external-only CTA, not a spinner/disabled approval. | unit + manual accessibility | same [ASSUMED] | ❌ Wave 0 |
| USAGE-01 | Handoff opens the exact official URL and never invokes credential/token code. | unit + source scan + manual browser smoke | same [ASSUMED] | ❌ Wave 0 |
| PRIV-01 | Privacy view contains all four data categories plus location/retention disclosure. | unit + manual VoiceOver check | same [ASSUMED] | ❌ Wave 0 |
| PRIV-05 | Target has no credential input, Keychain/OAuth/token tracker path, or private data reader. | source scan + manual first-launch check | `rg -n 'Keychain|OAuth|TokenTracking|ClaudeAPIService|HookSocketServer' CodexAtoll` [ASSUMED] | ❌ Wave 0 |

### Sampling Rate

- **Per task commit:** build/typecheck plus the smallest affected XCTest set once full Xcode is available. [ASSUMED]
- **Per wave merge:** full macOS XCTest suite and manual smoke: open/close notch, activate ChatGPT, open usage URL, verify unavailable copy/VoiceOver, and confirm no credential/accessibility prompt. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:197-202]
- **Phase gate:** full suite green and the manual handoff/privacy smoke must pass before `$gsd-verify-work`. [ASSUMED]

### Wave 0 Gaps

- [ ] `CodexAtollTests/CapabilityContractTests.swift` — covers fixed Desktop, usage-unavailable, and privacy copy/routes. [ASSUMED]
- [ ] `CodexAtollTests/DesktopHandoffLauncherTests.swift` — covers absent app, launch error, activation failure, and success result mapping. [ASSUMED]
- [ ] `CodexAtollTests` Xcode XCTest target and shared injectable launcher boundary. [CITED: https://developer.apple.com/documentation/xctest/defining-test-cases-and-test-methods]
- [ ] Full Xcode installed/selected to run build and tests. [VERIFIED: local `xcodebuild -version` on 2026-08-17]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | no | Phase 1 does not authenticate, read credentials, or create an account session. [VERIFIED: .planning/REQUIREMENTS.md:60] |
| V3 Session Management | no | No Codex session data is observed or persisted. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-CONTEXT.md:5-8] |
| V4 Access Control | yes | Do not expose approval/command/pause controls without a later source-owned integration. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-CONTEXT.md:49-53] |
| V5 Input Validation | yes | Treat app lookup and external URL creation as fixed local constants; do not interpolate user or task data. [ASSUMED] |
| V6 Cryptography | no | No secret/token material is handled in this phase. [VERIFIED: .planning/REQUIREMENTS.md:60] |

### Known Threat Patterns for native macOS handoffs

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Misleading Desktop progress/approval state | Spoofing | Fixed `Currently unobservable` capability and no session-derived UI. [VERIFIED: .planning/phases/01-honest-desktop-companion/01-UI-SPEC.md:115-125] |
| Credential harvest through inherited quota UI | Information disclosure | Delete/exclude OAuth/Keychain/token tracker paths; use official browser handoff only. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/Core/TokenTrackingManager+CredentialCache.swift:17-68] [VERIFIED: .planning/REQUIREMENTS.md:60] |
| UI automation acts on wrong external task | Elevation of privilege | Use `NSWorkspace` application activation only; never synthesize external UI input. [VERIFIED: .planning/PROJECT.md:13-26] |
| Old Sparkle feed updates the renamed app | Tampering | Remove/replace inherited feed URL/public key before enabling updater. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/Info.plist:20-26] |

## Sources

### Primary (HIGH confidence)

- [Claude Atoll local source](https://github.com/engels74/claude-atoll) — inspected app lifecycle, window/notch shell, module registry, menu pattern, inherited Sparkle identity, and unsafe OAuth/Keychain/hook paths. [VERIFIED: local source snapshot `4e7cf858faa3e013b73150a5e4d41355c4f5be4e`]
- [Apple NSWorkspace](https://developer.apple.com/documentation/appkit/nsworkspace) — application lookup, URL open, and asynchronous application launch. [CITED]
- [Apple NSRunningApplication activation](https://developer.apple.com/documentation/appkit/nsrunningapplication/activate%28options%3A%29) — activation may fail. [CITED]
- [OpenAI Codex pricing](https://chatgpt.com/codex/pricing/) — official usage dashboard link and plan-dependent limits. [CITED]

### Secondary (MEDIUM confidence)

- [OpenAI: Using Codex with your ChatGPT plan](https://help.openai.com/en/articles/11369540/) — Desktop settings/usage guidance and plan-/workspace-specific behaviour. [CITED]
- [OpenAI: Moving to the new ChatGPT desktop app](https://help.openai.com/en/articles/20001276/) — current ChatGPT desktop product includes Codex. [CITED]
- [Apple accessibilityReduceMotion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion) — system motion preference. [CITED]
- [Apple XCTest](https://developer.apple.com/documentation/xctest/defining-test-cases-and-test-methods) — native test-target pattern. [CITED]

### Tertiary (LOW confidence)

- No third-party source was relied upon; implementation-name and test-command assumptions are listed in the Assumptions Log. [ASSUMED]

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — native reuse and Apple APIs are directly inspected/documented. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/App/ClaudeAtollApp.swift:10-20] [CITED: https://developer.apple.com/documentation/appkit/nsworkspace]
- Architecture: HIGH — Phase 1 has no integration transport and the reference’s window lifecycle is directly inspectable. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/UI/Window/NotchWindowController.swift:15-96]
- Pitfalls: HIGH — reference code concretely shows the inherited side effects that violate the locked scope. [VERIFIED: /Users/dou/claude-atoll/ClaudeAtoll/App/AppDelegate.swift:46-95; /Users/dou/claude-atoll/ClaudeAtoll/Core/TokenTrackingManager+CredentialCache.swift:17-68]
- Official Desktop identifier and exact dashboard route: MEDIUM — confirmed on this machine/current official webpage but must be compatibility-probed before public release. [VERIFIED: /Applications/ChatGPT.app/Contents/Info.plist:195-196] [CITED: https://chatgpt.com/codex/pricing/]

**Research date:** 2026-08-17  
**Valid until:** 2026-08-24 for the ChatGPT desktop bundle/dashboard handoff; 2026-09-16 for the native shell and privacy boundary.
