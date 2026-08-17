# Domain Pitfalls

**Domain:** Public macOS notch companion for Codex CLI and ChatGPT Desktop Codex
**Researched:** 2026-08-17
**Confidence:** MEDIUM — recommendations are grounded in current official OpenAI and Apple documentation plus direct inspection of Claude Atoll. The negative finding about Desktop is intentionally limited to the public interfaces reviewed.

## Critical Pitfalls

### Pitfall 1: Treating Desktop as an attachable Codex client

**What goes wrong:** The product promises live Desktop task state, history, or direct approvals by reading app-private data, injecting into its process, or scraping Accessibility UI. There is no reviewed public third-party API that exposes arbitrary Desktop sessions this way. The public App Server is for a product that owns its own Codex threads; Desktop documentation describes its user-facing app and permission controls, not a companion API.

**Why it happens:** Claude Atoll has one cooperative CLI integration, so it is tempting to assume the Desktop app is another local data source.

**Consequences:** Fragile releases can display stale information or authorize the wrong task. OS/app updates break the integration, and a public app asks for excessive permissions without a defensible contract.

**Warning signs:** The proposed design mentions SQLite/JSON files under another app’s container, Accessibility text/pixel matching, AppleScript click automation, process injection, or an undocumented deep link. Acceptance tests require a private Desktop task ID.

**Prevention:** Ship Desktop as an explicitly labelled `Open ChatGPT` integration in v1. It may activate the app and hold a user-created reference, but it must never invent an activity state or direct approval. Gate any richer connector behind a documented OpenAI API and a separate capability check.

**Verification:** Before adding a Desktop capability, reproduce it against a publicly documented API on a clean macOS account and test task identity, history scope, approval cancellation, and post-update compatibility. Review OpenAI’s current Desktop, Permissions, and App Server docs at every release.

**Fallback:** Activate ChatGPT and explain that review remains in the original task.

**Phase:** 1 — capability contract and Desktop shell; revisit only in a future integration-discovery phase.

### Pitfall 2: Cloning Claude Atoll’s unauthenticated world-writable socket

**What goes wrong:** Claude Atoll binds `/tmp/claude-atoll.sock` and calls `chmod(..., 0o777)`. A Codex port that accepts lifecycle events or returns allow/deny decisions over an equivalent socket lets another local process spoof events, inspect data, or potentially cause a dangerous approval.

**Why it happens:** Unix sockets feel local and the reference bridge already works for a single-user development setup.

**Consequences:** A local attacker, malicious development dependency, or another account on a shared Mac can create fake approval prompts, race a real response, or learn prompt/tool data. The risk is especially severe because Codex’s `PermissionRequest` can allow shell escalation and managed-network access.

**Warning signs:** A fixed `/tmp` path, mode `0777`, no peer identity or per-launch secret, approval keyed only by session or tool name, or no replay protection appears in the design.

**Prevention:** Use a per-user runtime directory and a socket mode of `0600`; verify ownership before unlinking a stale path. Authenticate each bridge connection with an app-generated secret passed only to the installed hook, include protocol version plus request nonce, bind decisions to `{session_id, turn_id, request_id}`, and consume each nonce exactly once. Prefer an app-owned child process/stdin bridge for App Server threads where feasible.

**Verification:** Automated security checks must prove that another UID cannot connect, a wrong secret is rejected, duplicate/stale responses do not alter Codex, and an app restart cannot answer an old request. Manually test two simultaneous CLI sessions and two simultaneous requests in one session.

**Fallback:** On any transport/authentication/identity failure, emit no Hook decision so Codex presents its native prompt; show `Open terminal` rather than an approval button.

**Phase:** 2 — authenticated CLI bridge, before any direct approval UI.

### Pitfall 3: Approving a stale or misidentified request

**What goes wrong:** A notch button approves an action after the originating prompt timed out, was answered in the terminal, or was superseded by a different tool call. Matching a `PermissionRequest` to a cached `PreToolUse` call is unsafe: Codex’s current PermissionRequest payload documents `turn_id`, tool name, and tool input, but not `tool_use_id`; matching hooks also run concurrently.

**Why it happens:** The reference implementation correlates permissions with a tool-ID cache and retains sockets for five minutes. That was designed around a different hook schema.

**Consequences:** The wrong command, file change, MCP action, or network destination could execute; conversely, a valid request may appear permanently pending.

**Warning signs:** UI identity is a tool name or session ID alone; `Allow` remains enabled after a terminal action; more than one pending approval can be collapsed into one card; the approval dialog renders every request as shell text.

**Prevention:** Make a direct CLI Hook approval request-scoped and short-lived. Generate an Atoll nonce per hook invocation; show `Allow once` and `Deny` only while the authenticated hook is still connected; on close/timeout, disable the controls. Preserve the exact Codex payload and render command, file-change, MCP, and network approval contexts differently. In an Atoll-owned App Server thread, use its `itemId`, `threadId`, `turnId`, `availableDecisions`, and `serverRequest/resolved` lifecycle instead of Hook inference. Never default to `acceptForSession` or a persistent permission grant.

**Verification:** A scripted test matrix covers duplicate events, terminal answer first, app restart, hook timeout, cancellation, concurrent network destinations, and all `availableDecisions`. The check must assert that every indeterminate path produces no Hook decision or App Server `cancel`, never `accept`.

**Fallback:** Native Codex approval prompt, with focus-to-origin action. If an App Server request resolves before the click, display `Already resolved` and do nothing.

**Phase:** 3 — direct CLI approval; repeat for the optional App Server launch mode.

### Pitfall 4: Using transcript files as a supported history database

**What goes wrong:** The port copies `ConversationParser` and parses Codex `transcript_path` JSONL to claim full history, tool results, and completion state. Codex explicitly calls that transcript path convenient but not a stable hook interface.

**Why it happens:** Claude Atoll’s incremental JSONL parser is one of its strongest user-visible features.

**Consequences:** A CLI update silently corrupts or misorders history, leaks a path outside expected scope, or causes the state machine to mark an action complete incorrectly. Compatibility maintenance becomes unbounded.

**Warning signs:** The architecture imports a parser for arbitrary `.codex` transcript files; no schema/version fixture exists; post-update history tests are absent; history becomes available without the companion observing the session.

**Prevention:** Persist only normalized, live hook events captured while Atoll is enabled, with a visible retention policy. Promise full structured history only for threads Atoll launches through App Server: stable `thread/read` can retrieve stored turns, while experimental paginated history must stay off by default. Treat `transcript_path` as a debugging link, not input to the product model.

**Verification:** Regression fixtures from supported Hook/App Server schemas exercise event ordering, tool failure, compaction, subagents, interruption, and loss of connectivity. A CLI-version compatibility test verifies graceful `history unavailable` behavior when a transcript is missing or malformed.

**Fallback:** Display captured activity with timestamps or `History unavailable for this session`; never synthesize history from an unreadable file.

**Phase:** 2 — event model and privacy storage; Phase 4 — App Server-owned history.

### Pitfall 5: Breaking a user’s Codex configuration or trust flow

**What goes wrong:** An installer ports the Claude `settings.json` merger to `~/.codex` and overwrites TOML/JSON or project-level configuration. Codex loads matching hooks from multiple layers, retains all of them rather than replacing lower-precedence hooks, and requires user review/trust for non-managed hooks whenever their definition changes.

**Why it happens:** The existing installer assumes one JSON file and treats hook registration as an app-owned invariant.

**Consequences:** Duplicate notifications, slower turns, denied work because another hook wins, loss of user configuration, or a public release that appears broken because its hook awaits trust. Enterprise policies can disable user hooks or make managed hooks authoritative.

**Warning signs:** The installer rewrites `config.toml`, modifies repo `.codex/` automatically, adds both `hooks.json` and inline TOML in one layer, uses a mutable command path, or reports installation successful before `codex /hooks` has trusted it.

**Prevention:** Install one clearly owned, versioned user-level `~/.codex/hooks.json` entry or use an officially supported plugin package after validation; never alter project config without an explicit project-scoped action. Parse and round-trip the selected format, preserve every unrelated hook, use a lock and atomic replace, preview the exact diff, and remove only Atoll-marked entries on uninstall. Treat disabled/managed-hook configurations as a non-error capability state.

**Verification:** Test empty, malformed, concurrent, user-hook, plugin-hook, project-hook, disabled-hook, and managed-enterprise configurations. Upgrade and uninstall must be idempotent and byte-preserve unrelated content. A smoke test checks that Codex marks the shipped hook trusted and receives exactly one event per expected invocation.

**Fallback:** Keep the app usable without monitoring; provide copyable manual setup and a diagnostics view that names the blocked layer/trust state.

**Phase:** 2 — onboarding and hook installer.

### Pitfall 6: Shipping a security-sensitive public DMG with the reference release posture

**What goes wrong:** Codex Atoll inherits Claude Atoll’s ad-hoc signing and release workflow that explicitly skips notarization. The public app nevertheless asks users to install a hook that sees prompts, tool input/output, and possibly permission requests; it may also need Accessibility to focus terminal windows.

**Why it happens:** Ad-hoc signing is convenient during development, and Sparkle update signatures can be mistaken for macOS distribution trust.

**Consequences:** Gatekeeper warnings erode trust, enterprise deployment fails, updates become hard to audit, and a compromise of the update/signing pipeline is high impact. Asking for Keychain access for a quota meter further magnifies the trust problem.

**Warning signs:** Release CI passes `--skip-notarization`; `CODE_SIGN_IDENTITY=-`; a Sparkle key is optional; first-run instructions tell users to remove quarantine; the app has broad permissions without a privacy disclosure.

**Prevention:** Treat Developer ID signing, hardened runtime, least-privilege entitlements, notarization, staple verification, Sparkle EdDSA signing, reproducible release provenance, and a verified appcast as release gates. Do not carry forward Claude Atoll’s OAuth/Keychain quota tracking. Publish data handling, local retention, uninstall, and source-attribution notices before enabling hooks.

**Verification:** CI fails closed without Developer ID, notarization, staple, and Sparkle signatures. Test fresh installation and update on a clean macOS account, verify `spctl`/`stapler`, and conduct a release security review for socket permissions, logs, hook integrity, and notices.

**Fallback:** No public DMG until the release gates pass; source builds remain clearly labelled developer-only.

**Phase:** 5 — distribution hardening, with signing decisions established in Phase 1.

## Moderate Pitfalls

### Pitfall 1: Misreporting lifecycle state from incomplete or out-of-order Hooks

**What goes wrong:** The UI asserts a session is finished or waiting when it saw only a subset of the lifecycle. `SessionEnd` does not run for subagents, hooks can run concurrently, and specialized/hosted tool paths can opt out of the normal tool hook path.

**Prevention:** Model observation separately from truth: use `observedRunning`, `needsReview`, `connectionLost`, and `endedByEvent`; retain sequence/timestamps per turn; reconcile only from authoritative App Server events for companion-owned threads. Do not claim all tool activity is observed.

**Warning signs:** A global `idle` state after `Stop`, or a status card without source, turn, last-event time, and freshness.

**Verification:** Replay shuffled, dropped, duplicated, compacted, and subagent event traces and assert safe degradation rather than invalid transitions.

**Fallback:** Show `Status may be stale — open original` after a bounded freshness window.

**Phase:** 2 — normalized state machine.

### Pitfall 2: Creating an App Server mode that competes with ordinary CLI/Desktop sessions

**What goes wrong:** The implementation assumes App Server can transparently attach to every current CLI or Desktop conversation. It instead exposes a client protocol where the integrating product initializes, starts/resumes threads, and reads its own transport; remote WebSocket transport is documented as experimental and unsupported for production workloads.

**Prevention:** Brand this path `Started by Codex Atoll`; own its process, transport, thread IDs, persistence, and shutdown. Use stdio or a private Unix socket locally. Do not expose remote listening in v1.

**Warning signs:** A plan to scan existing CLI/Desktop sessions into App Server, bind `ws://0.0.0.0`, or turn on experimental APIs for core functions.

**Verification:** Kill/restart Atoll and Codex independently; confirm reconnection, explicit thread ownership, cancelled approvals, and no cross-thread event leakage.

**Fallback:** Existing work stays on the cooperative Hook path or opens in its native client.

**Phase:** 4 — optional App Server launch mode.

### Pitfall 3: Leaking prompts, commands, secrets, or user data through UI persistence and diagnostics

**What goes wrong:** Raw `tool_input`, `tool_response`, paths, MCP arguments, prompt text, or error messages enter Swift logging, crash reports, screenshots, notification banners, and a permanent local activity cache.

**Prevention:** Default to live-only data or short encrypted-at-rest retention; redact secrets before persistence/logging, reveal sensitive fields only on deliberate interaction, suppress sensitive notification previews, and offer clear-now/delete-on-uninstall controls. Collect explicit consent before enabling Hooks.

**Warning signs:** A debug log prints JSON payloads, diagnostics export raw events, notifications reveal commands on the lock screen, or retention is unspecified.

**Verification:** Seed credentials, personal data, MCP payloads, and shell commands into fixtures; inspect logs, caches, notifications, exported diagnostics, and crash-report attachments for redaction.

**Fallback:** Record metadata only (source, timestamp, category, state) and direct the user to the original session.

**Phase:** 1 — privacy contract; Phase 2 — bridge/storage implementation.

### Pitfall 4: Focusing the wrong terminal/window

**What goes wrong:** PID, TTY, title, tmux pane, or project matching becomes stale or reused. Accessibility is used to send keystrokes rather than merely activate a verified target.

**Prevention:** Resolve focus at click time using verified process ownership, terminal app/window identity, and current session/TTY; ask for Accessibility only for functionality that truly needs it. Never type, paste, or approve through Accessibility.

**Warning signs:** PID stored indefinitely, title-only matching, arbitrary `AXUIElement` actions, or a focus path that does not report failure.

**Verification:** Test Terminal, iTerm2, Warp, tmux, closed/reopened windows, PID reuse, multiple projects, and no-Accessibility environments.

**Fallback:** Activate the terminal app, copy the session/project reference, and clearly report that the exact window was not found.

**Phase:** 3 — navigation and accessibility.

### Pitfall 5: Presenting usage as a precise, local remaining-quota meter

**What goes wrong:** The port copies Keychain/OAuth extraction or calls an undocumented endpoint to calculate remaining usage. Official guidance says limits vary by plan, task complexity, model, and execution surface, and sends users to Codex’s usage page or limit banner.

**Prevention:** Provide an `Open Codex usage` action and a neutral plan-wide availability explanation. Do not read credentials, infer balance from token counts, or promise a reset time.

**Warning signs:** Keychain access in onboarding, an Authorization header built from local credentials, or a numerical quota UI without an official endpoint.

**Verification:** Test logged-out, Free/Go/Plus/Pro/Business/Enterprise policy states and confirm no credential prompt or local token access occurs.

**Fallback:** Link to the official usage surface and show `Usage details unavailable here`.

**Phase:** 1 — capability contract; Phase 5 — polish.

## Minor Pitfalls

### Pitfall 1: Letting Hooks slow or block ordinary Codex work

**What goes wrong:** A synchronous status hook waits too long for the notch or emits large context. Most hooks default to a 600-second timeout; Hook output can also affect the model context.

**Prevention:** Use background hooks for telemetry, bounded payload sizes, and short explicit timeouts. Keep the one synchronous `PermissionRequest` path short and fail open to the native prompt when Atoll is unavailable.

**Warning signs:** Turn latency tracks app responsiveness, hook output contains user history, or timeout values are omitted.

**Verification:** Benchmark disconnected app, slow app, and payload flood cases; ensure normal Codex work proceeds after the configured bound.

**Fallback:** Disable monitoring for that session and leave Codex interaction untouched.

**Phase:** 2 — bridge performance testing.

### Pitfall 2: Forgetting licensing, naming, and update-identity migration

**What goes wrong:** The fork removes Apache-2.0 notices, retains Claude-specific bundle identifiers/appcast URLs, or lets an old updater install an incompatible build.

**Prevention:** Preserve attribution/NOTICE files, establish Codex Atoll’s unique bundle ID/update feed/signing key before the first release, and design an explicit migration/rollback policy.

**Warning signs:** `com.engels74.ClaudeAtoll` or Claude appcast endpoints remain in production settings.

**Verification:** License audit plus clean-install/update/rollback tests from both products.

**Fallback:** Disable cross-product update migration; ask users to install the new app separately.

**Phase:** 1 — project foundation; Phase 5 — release verification.

## Phase-Specific Warnings

| Phase topic | Likely pitfall | Mitigation |
|---|---|---|
| 1. Capability contract and foundation | Treating feature parity as an API guarantee, especially for Desktop and quota | Publish a per-source capability matrix; explicitly mark unsupported functions and test the Desktop `Open ChatGPT` fallback. |
| 2. CLI Hooks bridge | Insecure local transport, destructive config mutation, stale state, transcript parsing | Use `0600` authenticated transport; preserve one owned hooks config; normalize live events only; record freshness and retention. |
| 3. Approvals and focus | Wrong or expired request is approved; focus automation performs an action | Bind response to nonce + Codex identifiers, consume once, use native-prompt fallback, and restrict Accessibility to activation. |
| 4. App Server launch mode | Attaching to work Atoll does not own or relying on experimental remote API | Make it an opt-in launcher, local-only transport, stable API subset, and explicit thread ownership. |
| 5. Public distribution | Ad-hoc/not-notarized DMG plus hidden data collection or Keychain reads | Developer ID + hardened runtime + notarization + signed appcast; privacy/onboarding/uninstall audit; no credential scraping. |
| Every release | Codex hook schema/capability change | Version the bridge protocol, run schema fixtures against supported Codex releases, and turn off direct approval on incompatibility. |

## Sources

- [Codex Hooks](https://learn.chatgpt.com/docs/hooks) — MEDIUM (official, checked 2026-08-17): concurrent configuration layers, trust review, hook coverage, input/output schemas, PermissionRequest semantics, timeouts, and transcript stability limitation.
- [Codex App Server](https://learn.chatgpt.com/docs/app-server) — MEDIUM (official, checked 2026-08-17): owned-client lifecycle, local/remote transports, experimental-surface boundary, history reads, structured approval and resolution lifecycle.
- [Codex permissions](https://learn.chatgpt.com/docs/permission-modes) and [ChatGPT desktop app](https://learn.chatgpt.com/docs/app) — MEDIUM (official, checked 2026-08-17): Desktop owns permission controls. No public third-party arbitrary-task API was found in these and the App Server documentation; this is a bounded negative finding, not a claim about private implementation.
- [Using Codex with your ChatGPT plan](https://help.openai.com/en/articles/11369540/) — MEDIUM (official, updated 2026-08-11): plan-dependent shared usage and usage-page/limit-banner guidance.
- [Apple Developer ID distribution guidance](https://developer.apple.com/developer-id/) — MEDIUM (official, checked 2026-08-17): Developer ID, hardened runtime, entitlements, and notarization for software distributed outside the App Store.
- Claude Atoll code inspection — HIGH for repository facts: `HookSocketServer.swift` uses `/tmp/claude-atoll.sock` with mode `0777`; its release workflow runs ad-hoc signing and invokes `--skip-notarization`; its history and quota paths are Claude-specific patterns that must not be copied blindly.
