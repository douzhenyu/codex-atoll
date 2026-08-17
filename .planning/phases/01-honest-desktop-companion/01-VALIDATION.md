---
phase: 1
slug: honest-desktop-companion
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-08-17
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest in a native macOS test target |
| **Config file** | none — Wave 0 creates `CodexAtollTests` in `CodexAtoll.xcodeproj` |
| **Quick run command** | `xcodebuild test -project CodexAtoll.xcodeproj -scheme CodexAtoll -destination 'platform=macOS'` |
| **Full suite command** | `xcodebuild test -project CodexAtoll.xcodeproj -scheme CodexAtoll -destination 'platform=macOS'` |
| **Estimated runtime** | ~60 seconds after full Xcode is installed and selected |

---

## Sampling Rate

- **After every task commit:** Run the smallest affected XCTest class, or the full command when the scheme cannot filter safely.
- **After every plan wave:** Run `xcodebuild test -project CodexAtoll.xcodeproj -scheme CodexAtoll -destination 'platform=macOS'`.
- **Before `/gsd:verify-work`:** The full suite and manual handoff/privacy smoke must pass.
- **Max feedback latency:** 60 seconds after test infrastructure is available.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01-01 | 1 | DESK-01 | T-01-01 | Renamed accessory app renders the static collapsed/open companion shell with neutral state and no inherited lifecycle side effects. | build + source scan | `xcodebuild build -project CodexAtoll.xcodeproj -target CodexAtoll -configuration Debug` plus the Plan 01 source scan | ❌ W0 | ⬜ pending |
| 01-01-02 | 01-01 | 1 | DESK-01 | T-01-01, T-01-03 | XCTest proves local open/close route, collapsed identity/accessibility, and forbidden shell inventory. | unit | `xcodebuild test -project CodexAtoll.xcodeproj -scheme CodexAtoll -destination 'platform=macOS' -only-testing:CodexAtollTests/CapabilityContractTests` | ❌ W0 | ⬜ pending |
| 01-02-01 | 01-02 | 2 | DESK-01, DESK-02, DESK-03 | T-02-01, T-02-04 | Complete Desktop card exposes one unobservable capability and uses only the fixed native ChatGPT activation route. | unit + manual accessibility | same full XCTest command | ❌ W0 | ⬜ pending |
| 01-02-02 | 01-02 | 2 | DESK-02 | T-02-03, T-02-05 | ChatGPT lookup, launch, activation failure, success, coalescing, timeout, and retry map to explicit outcomes without UI automation. | unit + source scan | same full XCTest command plus the Plan 02 source scan | ❌ W0 | ⬜ pending |
| 01-03-01 | 01-03 | 3 | USAGE-01 | T-03-01 | Usage action opens only `https://chatgpt.com/codex/settings/usage` and never fetches or fabricates quota data. | unit + source scan | same full XCTest command plus the Plan 03 source scan | ❌ W0 | ⬜ pending |
| 01-03-02 | 01-03 | 3 | USAGE-01 | T-03-05 | Usage/menu controls preserve fixed targets, bounded feedback, retry, accessibility labels, and overflow reachability. | unit + manual accessibility | same full XCTest command | ❌ W0 | ⬜ pending |
| 01-04-01 | 01-04 | 4 | PRIV-01, PRIV-05 | T-04-02 | Privacy view contains ordered prompt, tool/result, session metadata, processing location, retention, and credential/private-data exclusions. | unit | same full XCTest command | ❌ W0 | ⬜ pending |
| 01-04-02 | 01-04 | 4 | DESK-01, DESK-02, DESK-03, USAGE-01, PRIV-01, PRIV-05 | T-04-01–05 | Phase boundary rejects inherited side effects, private data, automation, and mutable external targets. | unit + source scan + build | full XCTest/build command plus the Plan 04 source scan | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `CodexAtollTests/CapabilityContractTests.swift` — fixed Desktop, usage-unavailable, privacy copy, routes, and prohibited-control assertions.
- [ ] `CodexAtollTests/DesktopHandoffLauncherTests.swift` — absent app, launch error, activation failure, and success outcome mapping.
- [ ] `CodexAtollTests` XCTest target and a small injectable `WorkspaceOpening` boundary around `NSWorkspace`.
- [ ] Full Xcode installed and selected so `xcodebuild` can build the app and run XCTest; Command Line Tools alone are insufficient.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Notch geometry, focal order, collapse/expand behavior, keyboard focus, and Reduce Motion | DESK-01, DESK-03 | Requires a running macOS window and visual/accessibility inspection. | Launch the app; open/close the notch; verify Codex mark left, neutral symbol right, Desktop card first, no spinner or task controls; enable Reduce Motion and repeat. |
| Activate installed ChatGPT Desktop | DESK-02 | External application activation depends on the installed app and WindowServer. | Click `Open ChatGPT`; confirm ChatGPT activates without claiming a specific task; temporarily make lookup fail and confirm the Applications fallback copy remains visible. |
| Open official usage page | USAGE-01 | Browser routing and authenticated official-page content are external. | Click `Open official Codex usage`; confirm the default browser opens `https://chatgpt.com/codex/settings/usage`; confirm Atoll does not request credentials or scrape the page. |
| VoiceOver reads full capability, handoff, and privacy content | DESK-03, PRIV-01 | Assistive output and navigation order require macOS accessibility inspection. | Navigate every Phase 1 control with VoiceOver and keyboard; confirm literal capability labels, full truncated copy, menu label, back action, and CTA remain reachable. |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
