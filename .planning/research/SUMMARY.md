# Project Research Summary

**Project:** Codex Atoll  
**Domain:** Public macOS notch and menu-bar companion for Codex CLI and ChatGPT Desktop Codex  
**Researched:** 2026-08-17  
**Confidence:** MEDIUM

## Executive Summary

Codex Atoll should be a native Swift macOS fork of Claude Atoll: retain the notch, menu-bar, window, state-stream, focus, updater, and onboarding shell; replace Claude-specific hooks, transcript parsing, approval, and quota code with Codex adapters. The v1 product is an attention and navigation surface, not a second Codex client. It must source-label every item and render capabilities per session rather than pretending CLI and Desktop expose equivalent control.

The dependable vertical path is Codex CLI hooks into a signed embedded helper and authenticated local bridge, reduced by a source-aware `SessionStore` actor into live state, activity, focus, and request-scoped approval. Codex App Server adds complete history, structured approvals, and rate limits only for threads started or resumed through an Atoll-owned connection. ChatGPT Desktop has no verified public third-party API for observing, selecting, reading, or approving arbitrary existing tasks; v1 must therefore deliver Desktop app activation and an honest unavailable/open-original state, with richer behavior gated behind a future official capability probe.

The release is security-sensitive: hooks see prompts and tool payloads and can participate in approvals. Do not inherit the reference project's world-writable `/tmp` socket, Python runtime dependency, credential scraping, tmux keystrokes, or ad-hoc distribution. Use a per-user authenticated IPC channel, one-time approval correlation, bounded fail-to-native behavior, explicit data-retention consent, Developer ID signing/notarization, and a signed Sparkle feed.

## Key Findings

### Recommended Stack

Use Swift 6, SwiftUI, and AppKit on the inherited macOS 15.6+ baseline. Keep existing Sparkle, swift-markdown, swift-subprocess, and the existing presentation/state patterns; pin OcclusionKit instead of tracking `main`. A bundled Swift hook helper eliminates the reference application's Python/`uv` runtime dependency. Generate or validate App Server schemas against the installed Codex version and negotiate its capabilities at startup.

**Core technologies:**

- Swift 6 + SwiftUI + AppKit: native notch UI, lifecycle, and accessibility integration — retains the proven macOS shell.
- Embedded Swift CLI hook helper: converts trusted Codex hook input into bounded local IPC and returns an exact decision only for a live permission request.
- `SessionStore` actor + `AsyncStream`: single, source-qualified state reduction boundary — prevents CLI transport details from leaking into Desktop UI.
- App Server JSON-RPC client actor: structured history, item lifecycle, approvals, and rate limits — only for Atoll-owned sessions and version-probed stable endpoints.
- Foundation/Network/Darwin: JSON decoding, process launch, file handling, and Unix IPC — no additional runtime or socket dependency needed.
- Developer ID signing, notarization, and Sparkle EdDSA feed: required public-DMG trust and update integrity.

### Expected Features

The non-negotiable experience is a unified but capability-aware queue: source badge, freshness, attention state, details captured while Atoll is connected, one-click return to the original client, privacy controls, diagnostics, onboarding, updates, and an official usage entry point. CLI can provide live status and a direct request-scoped approval route. Desktop support is still present in v1, but the supported promise is launch/focus and clear explanation of unavailable status/history/approval, not fabricated parity.

**Must have (table stakes):**

- Source-labelled CLI and Desktop cards with honest freshness and capability states.
- CLI live lifecycle, notification/attention state, safe terminal focus, and captured live activity.
- CLI `Allow once`/deny only for an authenticated, live `PermissionRequest`; otherwise focus the native prompt.
- Desktop `Open ChatGPT` fallback and never guessed lifecycle or approval controls.
- Explicit hook-install consent, reversible config changes, data-retention controls, diagnostics, public-DMG onboarding, updates, and docs.
- Official usage/limits handoff instead of a fabricated local meter.

**Should have (competitive):**

- Per-card capability explanation and urgency-ordered attention queue.
- Context-aware approval preview, local redaction/expiry, and a support diagnostics screen.
- Atoll-owned App Server launch mode with structured history, approvals, and rate limits.

**Defer (v2+ or official API availability):**

- Arbitrary existing CLI full-history import.
- Desktop task monitoring, transcript/history ingestion, task-specific deep links, and direct approval.
- Persistent approve-all/session-grant defaults, UI automation, private-store scraping, or credentials/undocumented quota APIs.

### Architecture Approach

Use a small adapter layer before the existing shared state reduction: `CLIAdapter`, `DesktopAdapter`, and optional `AppServerClient` emit normalized, source-qualified events plus live `SessionCapabilities`. `SessionStore` remains the sole state authority; a thin SwiftUI monitor and action router resolve focus, history, approval, and usage through the owning adapter. Never key a session by an unqualified thread identifier, and make a pending approval a capability with a live request id, not merely a visual phase.

**Major components:**

1. `CodexHookInstaller` and embedded `CodexHookBridge` — preview, merge, and remove only Atoll-owned CLI hooks; relay validated hook events over authenticated IPC.
2. `CLIAdapter` — normalize hook lifecycle, retain short live activity, correlate exact approvals, and coordinate terminal focus.
3. `DesktopAdapter` — activate ChatGPT and expose only evidence-backed capabilities; v1 does not parse private stores or infer task state.
4. `AppServerClient` — optional local, Atoll-owned process/connection for structured threads, items, approvals, and rate limits.
5. `SessionStore`, monitor, and action router — source-aware state, streams, and action dispatch for reused SwiftUI views.
6. `TerminalNavigator` and `DesktopNavigator` — resolve a terminal at click time or activate ChatGPT; neither sends synthetic input.

### Critical Pitfalls

1. **Insecure local bridge can permit spoofed events or approvals** — use owner-only runtime IPC, a per-launch secret, protocol/request nonces, exact `{session, turn, request}` binding, and fail to Codex's native prompt.
2. **Stale or misidentified approval can authorize the wrong tool** — render only live, single-use decisions; disable on timeout/disconnect/resolution and await canonical completion before updating status.
3. **Desktop parity is not a verified API promise** — do not scrape private databases, accessibility text, or UI state; activate the original app until an official attach/control surface is proven.
4. **Hook/transcript history can be incomplete, unordered, or unstable** — persist minimal normalized live events; mark freshness, replay adverse event traces, and restrict complete history to owned App Server threads.
5. **Configuration, privacy, and distribution failures undermine a public companion** — preserve unrelated hook configuration, require transparent consent and redaction, and make notarization, signed updates, attribution, and uninstall part of release gates.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Product Foundation and Capability Contract

**Rationale:** Establish the fork identity, public-release trust boundary, and truthful source contract before any privileged integration.

**Delivers:** Renamed product/bundle/update identity, preserved Apache attribution, a source-and-capability model, static source-labelled UI states, consent/privacy copy, Desktop activation fallback, official usage link, and signing/notarization plan.

**Addresses:** Unified task list, Desktop support, usage entry point, onboarding/release requirements.

**Avoids:** Claiming unsupported Desktop/quota APIs, inherited update identity, secret retention, and unsuitable ad-hoc release posture.

### Phase 2: Secure CLI Observation Vertical Slice

**Rationale:** CLI hooks are the verified live integration and must be safe before extending feature breadth.

**Delivers:** Idempotent hook installer, embedded bridge, owner-only authenticated local IPC, normalized source-qualified state, bounded CLI lifecycle monitoring, freshness/error states, notifications, and captured event trail.

**Addresses:** CLI live status, recent activity, configuration control, and attention queue.

**Avoids:** Config clobbering, world-writable sockets, blocking normal Codex work, incomplete-state claims, and raw-payload logging.

### Phase 3: CLI Navigation and Safe Direct Approval

**Rationale:** Focus and approval depend on the live CLI identity and bridge produced in Phase 2.

**Delivers:** Verified terminal/tmux focus with error fallback, request-scoped approval presentation, allow-once/deny/defer, nonce consumption, and canonical post-action reconciliation.

**Addresses:** Return to origin and direct approval where safely supported.

**Avoids:** PID/title-only focus, tmux/UI keystrokes, persistent approvals, stale/replayed approval responses, and optimistic completion state.

### Phase 4: Atoll-Owned App Server Sessions

**Rationale:** Full structured history, App Server approvals, and rate limits require explicit connection and thread ownership; they cannot be retrofitted onto arbitrary existing work.

**Delivers:** Opt-in local App Server launch/resume, version/schema capability probe, owned thread/item history, structured approval routing, and documented rate-limit presentation where available.

**Addresses:** Rich history, advanced approvals, user-input routing, and usage visibility for owned sessions.

**Avoids:** Hijacking CLI/Desktop sessions, remote/experimental endpoints, cross-thread approval leakage, and credential scraping.

### Phase 5: Desktop Companion Experience and Capability Gate

**Rationale:** Desktop belongs in the first release, but its guaranteed path is safe navigation—not guessed monitoring or control.

**Delivers:** Source-labelled Desktop entry/reference cards, robust ChatGPT activation, unavailable capability explanations, and a visible capability probe framework for future official Desktop APIs.

**Addresses:** Unified source experience and one-click original-client handoff.

**Avoids:** Private-store parsing, screen/accessibility scraping, task-selection claims, and direct approval absent a live documented channel.

### Phase 6: Public Release Hardening

**Rationale:** A public DMG must treat hook installation and approvals as a high-trust release concern.

**Delivers:** Developer ID signing, hardened runtime, notarized/stapled DMG, signed Sparkle appcast, compatibility diagnostics, fresh-install/update/uninstall tests, documentation, and privacy/security release checks.

**Addresses:** Public distribution, updates, supportability, and user trust.

**Avoids:** Gatekeeper failures, unsigned updates, accidental cross-product migration, and undisclosed local data handling.

### Phase Ordering Rationale

- Shared identity/capabilities and release policy come first because every UI action must accurately reflect source evidence.
- The CLI hook route is the only verified path for monitoring and direct action on existing work, so it precedes approval, history, and polish.
- App Server is an independent owned-session provider; its richer features must not create an attachment promise for CLI/Desktop sessions.
- Desktop ships from Phase 1/5 as a first-class, labelled navigation fallback and upgrades only after official capability validation.
- Public distribution follows functional security gates, but its signing identity and privacy contract must be decided in Phase 1.

### Research Flags

Phases likely needing deeper research during planning:

- **Phase 2:** Current Codex hook config layering, trust, timeout/cancellation semantics, event shapes, concurrent approvals, and authenticated IPC feasibility must be spiked on supported CLI versions.
- **Phase 3:** Approval correlation and terminal focus require adversarial fixtures across terminal apps, tmux, disconnects, duplicate requests, and native-prompt races.
- **Phase 4:** Verify the installed App Server schema, lifecycle ownership, local transport behavior, and stable rate-limit/approval methods before committing APIs.
- **Phase 5:** Blocked on a documented ChatGPT Desktop task/event/deep-link/control surface. Research only if OpenAI publishes one; otherwise retain the fallback.
- **Phase 6:** Validate current Apple signing/notarization and Sparkle release requirements with release credentials and a clean macOS account.

Phases with standard patterns (skip research-phase):

- **Phase 1 UI shell:** Claude Atoll's macOS shell and Swift actor/stream pattern provide a direct, inspectable starting point.
- **Usage entry point:** A neutral official-link action is standard and intentionally avoids an integration.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | MEDIUM | Native reuse and documented CLI/App Server surfaces are strong; App Server capability/version variation and public-release details need implementation validation. |
| Features | MEDIUM | CLI capabilities are documented; Desktop's absence of a public third-party API means its v1 feature set is deliberately constrained. |
| Architecture | MEDIUM | The adapter/state separation follows the reference's proven shell and documented protocol ownership, but local transcript/desktop-reader suggestions conflict across research. |
| Pitfalls | HIGH | Security, permission, configuration, privacy, and distribution risks are consistently identified and directly applicable to this fork. |

**Overall confidence:** MEDIUM

### Gaps to Address

- **Existing Desktop task discovery and history:** Research conflicts: some notes propose best-effort local record reading, while feature and safety research reject private-store parsing. Resolve conservatively for v1: no private-store reader or status/history promise; only source-labelled reference/activation until an official public surface exists.
- **Desktop direct approval:** No supported attachment/control API was verified. It is a blocker for parity, not a reason to automate the UI; retain `Open ChatGPT`.
- **Existing CLI full history:** `transcript_path` is not a stable contract. Capture live normalized activity only; give full history solely to Atoll-owned App Server threads.
- **Rate-limit display:** Conflicting guidance must be capability-gated. Offer the official usage link universally; show App Server data only when an owned, version-supported connection returns it.
- **Codex version compatibility:** Hook and App Server protocols evolve. Maintain versioned fixtures and disable direct control on mismatches.

## Sources

### Primary (HIGH confidence)

- [Official Codex Hooks documentation](https://developers.openai.com/codex/hooks) — lifecycle hooks, configuration, trust, and permission-decision semantics.
- [Official Codex App Server documentation](https://developers.openai.com/codex/app-server) — owned-client protocol, threads, item lifecycle, approvals, and rate limits.
- [Codex App Server implementation README](https://github.com/openai/codex/blob/main/codex-rs/app-server/README.md) — evolving transport/schema implementation details.
- Local Claude Atoll inspection — source facts on reusable Swift macOS components and unsafe inherited socket/release/Claude-specific integration patterns.

### Secondary (MEDIUM confidence)

- [Codex Hooks documentation mirror](https://learn.chatgpt.com/docs/hooks) — configuration layering, hook coverage, transcript limitations, and permission behavior.
- [Codex App Server documentation mirror](https://learn.chatgpt.com/docs/app-server) — owned-session boundaries and structured request lifecycle.
- [ChatGPT Desktop/Codex overview](https://help.openai.com/en/articles/20001275-chatgpt-work-and-codex) — Desktop product behavior and bounded lack of a verified third-party task API.
- [Codex usage guidance](https://help.openai.com/en/articles/11369540/) — plan-dependent limits and official usage surface.
- [Apple Developer ID guidance](https://developer.apple.com/developer-id/) — distribution signing, hardened runtime, and notarization.

---
*Research completed: 2026-08-17*  
*Ready for roadmap: yes*
