# Walking Skeleton — Codex Atoll

**Phase:** 1
**Generated:** 2026-08-17

## Capability Proven End-to-End

A Codex user can open the native notch companion, see an explicitly unobservable Codex Desktop card, and ask macOS to activate ChatGPT without Codex Atoll reading or inferring task data.

## Architectural Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Framework | Swift 6 with SwiftUI and AppKit on macOS 15.6+ | Reuses Claude Atoll's proven custom-panel/notch shell while keeping the UI native. |
| Interaction path | SwiftUI view → `NotchViewModel` local route → `DesktopHandoffLauncher` → `NSWorkspace` | This is the complete Phase 1 stack; success means macOS accepted an app/URL launch, never that a Codex task was observed or selected. |
| Data layer | none — Phase 1 owns no persistent user/session data | Desktop status, usage values, credentials, and integration state have no supported source in this phase. Database read/write are not applicable at this boundary. |
| Auth | none — Phase 1 authenticates no user or Codex account | ChatGPT and the official usage page retain their own account context; Codex Atoll never receives credentials. |
| Runtime target | Local signed-by-Xcode macOS app run from `CodexAtoll.xcodeproj` | Full Xcode is the required build/runtime environment; public signing, notarization, DMG, and updates belong to Phase 6. |
| Directory layout | `CodexAtoll/{App,Core,UI}` plus `CodexAtollTests` | Preserves the reference app's native responsibility split without importing its monitoring, hooks, token, or updater subsystems. |
| Source provenance | Apache-2.0 Claude Atoll snapshot `4e7cf858faa3e013b73150a5e4d41355c4f5be4e` with retained license and modification notice | Keeps reuse auditable and compliant while copying only the shell files Phase 1 needs. |

## Stack Touched in Phase 1

- [ ] Project scaffold — renamed Xcode app and XCTest targets, generated app Info.plist, localizable strings, and inherited native shell.
- [ ] Routing — real local routes for companion, usage-unavailable, menu, and Privacy & Data surfaces.
- [ ] Database — not applicable; the phase intentionally performs no persistent read or write because it owns no user/session data.
- [ ] UI — native buttons invoke the tested `NSWorkspace` boundary for ChatGPT activation and the fixed official usage URL.
- [ ] Runtime — after full Xcode is installed and selected: `xcodebuild test -project CodexAtoll.xcodeproj -scheme CodexAtoll -destination 'platform=macOS' && xcodebuild build -project CodexAtoll.xcodeproj -scheme CodexAtoll -configuration Debug -derivedDataPath .build && open .build/Build/Products/Debug/CodexAtoll.app`.

## Sequential Execution Slices

1. Product identity, Apache attribution, app/XCTest targets, and shared scheme.
2. Native accessory-panel notch shell and neutral local companion route.
3. Source-labelled Desktop card and verified-identifier ChatGPT activation.
4. Usage-unavailable detail, official usage URL, and local menu.
5. Privacy & Data disclosure and phase-wide boundary proof.

## Out of Scope (Deferred to Later Slices)

- Live CLI lifecycle, task-progress animation, attention events, notifications, and diagnostics (Phase 2).
- Terminal/tmux return and request-scoped approval decisions (Phase 3).
- Atoll-owned App Server sessions, structured history, supported controls, and authoritative rate limits (Phase 4).
- Integration onboarding, removal, retention controls, and user documentation (Phase 5).
- Developer ID signing, notarized DMG, and signed Sparkle updates (Phase 6).
- Arbitrary Codex Desktop task state, history, deep links, or approvals until an official public surface exists.

## Subsequent Slice Plan

- Phase 2: Add consented, authenticated Codex CLI monitoring to the same source-labelled notch shell.
- Phase 3: Add safe terminal navigation and exact live permission decisions.
- Phase 4: Add opt-in Atoll-owned App Server sessions and authoritative usage data.
- Phase 5: Add guided setup, privacy controls, diagnostics, documentation, and removal.
- Phase 6: Deliver the signed, notarized public release and verified update path.
