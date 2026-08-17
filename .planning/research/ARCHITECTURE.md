# Architecture Patterns

**Domain:** macOS notch companion for Codex CLI and ChatGPT desktop Codex tasks  
**Researched:** 2026-08-17  
**Confidence:** MEDIUM — Claude Atoll source was traced locally; CLI protocols and hooks are confirmed in current OpenAI documentation. OpenAI does not document an API for attaching a third-party client to an already-running desktop task, so that path must capability-check and degrade safely.

## Recommended Architecture

Keep Claude Atoll's macOS shell and replace its Claude-specific integration spine with two independent Codex adapters that normalize only after source-specific collection and control decisions.

```text
Codex CLI                                      ChatGPT desktop app — Codex
----------                                     ----------------------------
hooks.json command bridge                      transcript/index discovery + app focus
  (Session/turn/tool events)                     optional hook events when capability probe passes
        |                                                       |
        +--> CLIAdapter ------------------+  +--> DesktopAdapter ---------+
             validates + maps                    validates + maps           |
                                                                    v
                                                        NormalizedSessionEvent
                                                                    |
                                                                    v
                                                          SessionStore actor
                                                                    |
                                                                    v
                                                   AsyncStream / CodexSessionMonitor
                                                                    |
      +-------------------------- reusable Claude Atoll macOS shell -------------------------+
      | NotchWindow, WindowManager, NotchViewModel, module layout, SwiftUI chat/list,        |
      | notifications, accessibility onboarding, Sparkle/release infrastructure               |
      +-----------------------------------------------------------------------------------------+

Direct approval routes only to the adapter that owns a live, authenticated request:
  CLI PermissionRequest hook -> bridge's stdin response -> Codex CLI
  Atoll-owned app-server thread -> JSON-RPC response -> its app-server process
  Existing desktop task without a verified bridge -> focus the desktop task; no simulated click
```

The separation is non-negotiable. A terminal CLI session can be observed and controlled through Codex lifecycle hooks. An already-running desktop task is not the same transport or ownership boundary. Treat it as a separately discovered local thread until a documented, live control channel proves otherwise. The app-server is the preferred active-session protocol only when Codex Atoll starts or resumes that app-server connection itself; it streams thread/turn/item lifecycle data and routes approval responses to that connection, not to arbitrary existing Codex clients. [OpenAI app-server docs](https://developers.openai.com/codex/app-server), [protocol source](https://github.com/openai/codex/blob/main/codex-rs/app-server/README.md)

### Component Boundaries

| Component | Responsibility | Communicates With |
|---|---|---|
| `CodexHookInstaller` | Install/remove only Codex Atoll-owned command entries in `~/.codex/hooks.json` (or supported config representation); preserve unrelated hooks and record an install version. | Bundled bridge, Codex CLI config, onboarding UI |
| `CodexHookBridge` | Read the one JSON event from stdin, authenticate it to a user-only Unix socket, send a bounded normalized bridge message, and for `PermissionRequest` wait for an allow/deny/defer response. | `CLIAdapter`, Codex hook process |
| `CLIAdapter` | Map documented hook events, `session_id`, `turn_id`, tool metadata, and transcript hint into CLI source events. It owns hook-backed approval replies. | Bridge, history reader, terminal navigator, `SessionStore` |
| `DesktopAdapter` | Discover Codex-local threads/transcripts, derive coarse task status and history when readable, and offer desktop-app focus. It must advertise no direct approval until a live, documented source channel is verified. | filesystem watcher/index reader, `DesktopNavigator`, `SessionStore` |
| `AppServerClient` | Optional provider for sessions Codex Atoll starts/resumes through `codex app-server`; handles JSON-RPC handshake, schema/version capability probe, stream, direct approvals, history, and rate limits. Not an attachment mechanism for another client's live turn. | Codex subprocess/socket, `CLIAdapter` capabilities, `SessionStore`, usage service |
| `CodexTranscriptReader` | Best-effort incremental read of a hook-provided transcript path or known local thread store. Maps messages/tool results into shared chat items; never makes approval decisions from a file. | adapters, `SessionStore` |
| `SessionStore` actor | One source of truth for source-labelled session state. Receives normalized events; validates phase transitions; publishes snapshots. | all adapters, `CodexSessionMonitor` |
| `CodexSessionMonitor` | Thin `@Observable` MainActor projection of `SessionStore.sessionsStream()` for existing SwiftUI. Dispatches an action through the session's capability instead of talking to a global socket. | SwiftUI views, action router |
| `SessionActionRouter` | Resolves `focus`, `approve`, `deny`, `defer`, `loadHistory`, and `refreshUsage` by source/session capability. | navigator(s), adapters, app-server client |
| `DesktopNavigator` / `TerminalNavigator` | Focus the ChatGPT desktop app or terminal window. Terminal focus may reuse the process-tree/Accessibility path; desktop focus uses `NSRunningApplication` by bundle ID and reports inability to locate a specific task. | `SessionActionRouter`, AppKit |
| `UsageService` | Read rate limits only through `AppServerClient.account/rateLimits/read`; expose unavailable rather than scraping Keychain/private endpoints. | app-server client, token-ring module |

### Reuse vs. Replace Map

| Claude Atoll area | Codex Atoll decision | Reason |
|---|---|---|
| `App/AppDelegate.swift`, `WindowManager.swift`, `UI/Window/*`, `NotchViewModel.swift`, module layout, settings and Sparkle wiring | Reuse, rename product identifiers and audit permissions. | These are source-agnostic macOS presentation and release concerns. |
| `SessionStore.swift`, `SessionState.swift`, `SessionPhase.swift`, `ChatMessage.swift`, `ChatItemFactory.swift` | Evolve in place into source-aware generic state, not duplicate stores. | The actor/`AsyncStream` ownership model is exactly the needed normalization boundary. |
| `ClaudeSessionMonitor.swift` | Rename to `CodexSessionMonitor`; keep stream projection but delegate actions to `SessionActionRouter`. | Prevents CLI-only socket calls from leaking into Desktop rows. |
| `HookSocketServer.swift` | Reuse the Unix-socket mechanics only after tightening socket ownership/permissions; replace `HookEvent` and response schemas with Codex bridge messages. | Codex command hooks receive one JSON object on stdin and emit a JSON decision; their payload differs from Claude's hooks. |
| `HookInstaller.swift`, bundled `claude-atoll-state.py` | Replace with a Codex hook installer and small bridge. | Codex uses `hooks.json`/`config.toml`, supports distinct lifecycle names, hook trust, and a documented `PermissionRequest` decision shape. |
| `ConversationParser.swift`, JSONL interrupt watcher | Replace with `CodexTranscriptReader` plus filesystem/index watcher; gate it as best-effort. | Hook `transcript_path` is provided for convenience but its format is explicitly not stable. |
| `TerminalFocuser.swift` and process-tree helpers | Reuse and retarget process matching from `claude` to `codex`; add a separate `DesktopNavigator`. | CLI and desktop navigation have different identities. |
| tmux `ToolApprovalHandler` | Remove from approval path. | Sending keys is brittle and conflicts with the explicitly chosen safe-integration boundary. |
| `TokenTrackingManager.swift`, `ClaudeAPIService.swift`, CLI OAuth Keychain reader | Replace with `UsageService` backed by app-server `account/rateLimits/read`; do not read desktop/CLI credentials. | The app-server documents rate-limit data and avoids duplicating or exposing user auth tokens. |
| `ReleaseService.swift`, Sparkle user driver, DMG scripts/docs | Reuse with repository URL, bundle id, feed signature/notarization, and Codex attribution updates. | Distribution mechanics remain independent of the agent source. |

## Normalized Model and Capability Negotiation

Do not use a protocol with a single concrete implementation. Two real source adapters justify one small shared contract: an adapter emits `NormalizedSessionEvent` and returns a per-session `SessionCapabilities` value. Keep all provider-specific payloads behind that boundary.

```swift
enum SessionSource: Sendable { case cli, desktop }

struct SessionCapabilities: Sendable {
    let canFocus: Bool
    let canReadHistory: Bool
    let approval: ApprovalCapability
    let canReadUsage: Bool
}

enum ApprovalCapability: Sendable {
    case direct(requestID: String)       // Hook or Atoll-owned app-server request
    case focusOrigin(message: String)    // Existing desktop/native prompt
    case unavailable(message: String)
}
```

`SessionState` should gain `source`, a source-qualified stable id (`"cli:<thread-id>"` or `"desktop:<thread-id>"`), `origin`, and `capabilities`. Do not key the global dictionary by bare thread ID: CLI and desktop stores can expose the same underlying UUID or merge history at different times. Preserve the existing phase vocabulary (`idle`, `processing`, `waitingForInput`, `waitingForApproval`, `compacting`, `ended`), but model any unknown source status as `idle`/`processing` with a visible source status detail rather than inventing a false terminal state.

At adapter start, calculate capabilities from observed evidence, not assumptions:

1. Verify the installed Codex version and the effective hook configuration/trust state before calling the CLI hook bridge available.
2. For an app-server connection owned by Codex Atoll, complete `initialize`, retain the server version/schema result, and opt out of experimental endpoints by default. Use stable `thread/*`, item lifecycle, approval, and rate-limit endpoints; generated schemas are version-specific. [OpenAI app-server docs](https://developers.openai.com/codex/app-server)
3. For a desktop task, start with `canFocus` and read-only history only if its local record is readable. Upgrade to direct approval only after receiving a live request that the adapter itself can answer; never infer it from a pending transcript item.
4. Refresh the capability value on reconnect, hook failure, app update, config change, or request resolution. SwiftUI renders that value, so buttons cannot outlive the transport that justified them.

## Data Flow

### CLI: live status, history, and approval

1. Onboarding installs a user-visible Codex Atoll handler for `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PreCompact`, `PostCompact`, `Stop`, `SubagentStart`/`SubagentStop`, and `SessionEnd`; it must not overwrite other matching hooks because Codex runs matching hooks from multiple layers. [Hooks documentation](https://developers.openai.com/codex/hooks)
2. The command bridge reads the hook's stdin object, validates required identifiers, opens the local socket, and emits a source-tagged event with `session_id`, `turn_id`, `cwd`, `tool_use_id`, tool input, and the optional transcript path. Codex documents these fields, but calls the transcript path convenience-only and unstable. [Hook inputs](https://developers.openai.com/codex/hooks)
3. `CLIAdapter` maps events to the shared lifecycle, schedules a debounced transcript refresh for display-only enrichment, and publishes through the actor.
4. A `PermissionRequest` bridge stays synchronous and waits only for the bounded direct decision. In the UI, `Approve`/`Deny` sends `allow`/`deny` to that exact bridge request; `Defer` returns no decision so Codex's native prompt remains responsible. Codex permits allow, deny, or normal prompting; multiple hook decisions can exist, with deny taking precedence. [PermissionRequest semantics](https://developers.openai.com/codex/hooks)
5. `PostToolUse`/the final transcript result resolve the UI item. Do not mark a tool successful merely because approval was clicked.

### Desktop: discover first, control only when owned

1. `DesktopAdapter` watches the user-selected local Codex data locations and/or reads the thread index at a conservative interval; it correlates readable records by thread id and working directory.
2. It maps a task's last persisted activity into a source-labelled `SessionState`, then loads history incrementally only when the user opens it. Corrupt/partial lines are retried on the next change; no destructive repair or database write belongs in Codex Atoll.
3. `Focus` activates the ChatGPT desktop app (the current desktop product hosts Codex as a separate view); it may open the app but must not claim a precise thread was selected without a public deep-link or active local control channel. [Desktop Codex overview](https://help.openai.com/en/articles/20001275-chatgpt-work-and-codex)
4. A detected native pending approval renders `Focus to review` rather than `Approve`/`Deny`. Current public docs describe desktop product permissions, but not an attach/control API for another app's active task. This is a product limitation, not an error state.
5. If a supported desktop execution path delivers the same trusted lifecycle hook bridge, it may contribute status/history events; direct approval remains off until the bridge's live request/response round trip succeeds for that exact version. Hook parity has changed across host releases, so ship the probe and visible fallback rather than assuming CLI behavior. [Hooks documentation](https://developers.openai.com/codex/hooks)

### Atoll-owned app-server sessions: full native path

1. `AppServerClient` starts `codex app-server` for an Atoll-created/resumed thread, performs JSON-RPC initialization, then drives `thread/start`/`thread/resume` and consumes `thread/started`, turn, and item notifications.
2. `item/started` produces an in-progress chat/tool item; `item/completed` is authoritative for final status. Command/file approval requests carry `threadId` and `turnId` and are answered on the same connection. [Item and approval lifecycle](https://developers.openai.com/codex/app-server)
3. `thread/list`/`thread/read` supply supported persisted history; `account/rateLimits/read` supplies quota UI. Do not enable experimental pagination/filter calls just to fill the first public release. [Thread listing](https://developers.openai.com/codex/app-server), [rate limits](https://developers.openai.com/codex/app-server)

## Patterns to Follow

### Pattern 1: Source-adapt before state reduction

**What:** Map each inbound source payload into a small, source-qualified event before `SessionStore` sees it.

**When:** Always. The store must never parse Codex hook JSON, inspect app-server JSON-RPC, touch a transcript, or activate an app.

**Example:**

```swift
func ingestHook(_ payload: CodexHookPayload) async {
    let event = NormalizedSessionEvent(
        id: .init(source: .cli, threadID: payload.sessionID),
        phase: phase(for: payload),
        source: .cli,
        capability: capability(for: payload),
    )
    await SessionStore.shared.process(.sourceEvent(event))
}
```

### Pattern 2: Approval is a live capability, not a phase side effect

**What:** A session may be `waitingForApproval` while direct approval is unavailable. The UI action comes from `ApprovalCapability`, not `SessionPhase` alone.

**When:** Any source can report a pending request.

**Why:** This keeps the desktop fallback honest and prevents a stale/replayed file record from authorizing code execution.

### Pattern 3: Canonical result wins over optimistic UI

**What:** Approval updates the pending control to resolving; only a `PostToolUse`, hook failure, or app-server `item/completed` finalizes the tool item.

**When:** CLI hook and app-server approval paths.

**Why:** Codex app-server explicitly marks `item/completed` authoritative, and external native approvals can race the notch UI.

### Pattern 4: Reuse macOS shell, keep product adapters thin

**What:** Preserve the window, notch, module layout, notifications, AppKit focusing, settings, and updater components. Replace integrations at named seams rather than branching the view hierarchy by source.

**When:** Throughout the port.

**Why:** The reusable part of Claude Atoll is the macOS companion experience; duplicating it for CLI/Desktop makes source-specific behavior leak across all UI code.

## Anti-Patterns to Avoid

### Anti-Pattern 1: One global hook socket with implicit CLI semantics

**What:** Replacing `ClaudeSessionMonitor` labels but retaining `HookSocketServer.respondToPermission` as the only approval action.

**Why bad:** A Desktop row could send an approval to a CLI bridge with a coincident identifier, or present a response control with no live transport.

**Instead:** Source-qualified IDs and `SessionActionRouter` resolve an action through the owning adapter.

### Anti-Pattern 2: Treating transcript JSONL as the control plane

**What:** Watching `~/.codex` records and calling a tool approved because a file was edited or a status changed.

**Why bad:** OpenAI states hook `transcript_path` is not a stable interface. Persisted files can lag, truncate, or be shared by different sources.

**Instead:** Use transcripts for best-effort history and recovery; use only live hook/app-server requests for control.

### Anti-Pattern 3: tmux/UI scripting for approvals

**What:** Sending keys to a CLI pane or accessibility-clicking a desktop prompt.

**Why bad:** It violates the safety requirement, is layout/version dependent, and can target the wrong terminal/task.

**Instead:** Direct hook decision when available; otherwise surface `Focus to review`.

### Anti-Pattern 4: Starting an app-server just to hijack a desktop thread

**What:** Call `thread/read`/`thread/resume` on a new app-server client and assume it can resolve the desktop client’s pending approval.

**Why bad:** App-server approvals are server-initiated requests to the client connection driving the turn. Resuming alters ownership/lifecycle and can race live work.

**Instead:** Use app-server as Codex Atoll's own full-session provider; existing desktop tasks remain discover/focus unless OpenAI publishes an attach API.

## Security and Privacy Boundaries

| Boundary | Required control |
|---|---|
| Hook stdin and transcript content | Treat as untrusted data. Decode to strict Codable schemas, impose message/path/field-size limits, reject unknown request correlation, and never execute hook-provided strings as shell commands. |
| Local socket | Create a per-user path with owner-only permissions; authenticate a short-lived launch secret generated by the app; include request and source IDs in every response; reject peers/requests that fail validation. The reference's world-writable socket mode must not be carried forward. |
| Approval | Default to `defer` on timeout, disconnect, invalid state, unknown capability, or version mismatch. A response may only resolve its exact live request id; audit decision, source, request id, and result without persisting command content by default. |
| Hook configuration | Merge only Codex Atoll-owned entries, preserve other handlers, expose exactly what will run, respect Codex hook trust and enterprise-managed constraints, and make uninstall symmetric. Codex can load hooks from multiple layers, so never replace the whole configuration. |
| History | Read only paths anchored to the user's approved Codex data directory or a currently received, canonicalized transcript path. Render tool output as data; redact or avoid logging tokens, secrets, and full commands by default. |
| Desktop control | Accessibility permission authorizes focus only. It must never justify synthetic approval clicks or input injection. |
| Usage/auth | Use app-server's authenticated rate-limit endpoint for Atoll-owned sessions; do not pull OAuth tokens from Keychain or private desktop stores. |

## Scalability Considerations

| Concern | At 100 users | At 10K users | At 1M users |
|---|---|---|---|
| Local event volume | One actor plus debounced per-session transcript reads is sufficient. | Same app architecture; keep parsing bounded and measure memory per long thread. | Still local-client work; optimize parser cache/retention, not a central service. |
| Transcript size | Parse incrementally on change and load full history only on demand. | Add item pagination in the chat view before raising file read limits. | Require app-server/history pagination where available; never preload all transcripts. |
| Provider evolution | Probe Codex CLI/app-server capability at launch and show fallback. | Version telemetry with consent; maintain compatibility fixtures for supported versions. | Maintain a formal protocol compatibility matrix and automated fixture corpus. |
| Public release | Sparkle + DMG with onboarding; no credential migration. | Signed/notarized releases, release-channel rollout, crash reporting with consent. | Managed config/enterprise install policy and supportable update rollouts. |

## Vertical Build Order

1. **Rebrand and preserve the macOS shell** — fork attribution/license, bundle id, app/update configuration, notch/window/UI smoke build. This isolates distribution risk before integrations.
2. **Introduce source-qualified shared state** — evolve `SessionState`, `SessionEvent`, `SessionStore`, and monitor/action router; render static CLI/Desktop rows with source badges and unavailable states. This is the normalization seam every following slice uses.
3. **CLI live vertical slice** — installer + bridge + private socket + `CLIAdapter` for start/process/ready/stop + terminal focus. Deliver real status and navigation without history or approval first.
4. **CLI history and direct approval** — incremental transcript reader, full chat view, exact request correlation, timeout/defer and authoritative completion handling. Add security tests around malformed events and stale approvals.
5. **Desktop read/focus vertical slice** — discover local Codex task records, source-labelled history, activate the ChatGPT desktop app, and render `Focus to review` for pending work. This satisfies the safe universal Desktop path without claiming a hidden control API.
6. **App-server-owned sessions and usage** — launch/resume owned threads only; consume lifecycle/items, implement direct app-server approvals, and fetch documented rate limits. Keep experimental endpoints off.
7. **Desktop capability probe and release hardening** — optional hook bridge only after verified host support; installer conflict/trust UX, migration/uninstall, accessibility/privacy copy, notarized DMG, Sparkle feed, documentation and compatibility tests.

## Sources

- [OpenAI Codex hooks — lifecycle events, configuration, input/output, and PermissionRequest](https://developers.openai.com/codex/hooks) — MEDIUM (official, current documentation; provider classification)
- [OpenAI Codex app-server — lifecycle, history, approval, and rate-limit protocol](https://developers.openai.com/codex/app-server) — MEDIUM (official, current documentation; provider classification)
- [OpenAI Codex app-server protocol repository](https://github.com/openai/codex/blob/main/codex-rs/app-server/README.md) — MEDIUM (official source, current `main`; protocol evolves)
- [OpenAI: ChatGPT Work and Codex desktop behavior](https://help.openai.com/en/articles/20001275-chatgpt-work-and-codex) — MEDIUM (official current product documentation)
- Local source inspection: `/Users/dou/claude-atoll/ClaudeAtoll/{App,Core,Models,Services,UI}` — HIGH for the reference code's current component boundaries.
