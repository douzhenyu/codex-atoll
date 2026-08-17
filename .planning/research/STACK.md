# Technology Stack

**Project:** Codex Atoll  
**Researched:** 2026-08-17  
**Confidence:** MEDIUM — Codex’s published integration APIs are current, but the App Server deliberately has capability-gated and experimental areas.

## Recommendation

Keep Claude Atoll’s native macOS implementation and replace the Claude-specific bridge with two Codex adapters. Do not create an Electron app, scrape credentials, or automate Codex’s UI. The smallest supportable design is:

```text
Codex CLI ── trusted lifecycle hooks ──> embedded Swift hook helper ──> local Unix socket ┐
                                                                                          ├─> SessionStore actor ─> SwiftUI notch
Codex App Server ── JSON-RPC client actor ──> threads/events/history/limits ──────────────┘
Codex Desktop ── App Server or read-only local thread store ──> Desktop adapter ──────────┘
```

Use hooks for live interactive CLI status and its synchronous `PermissionRequest` decision. Use App Server for structured thread/history/usage data, and for direct approvals only on the App Server connection that owns the pending request. Desktop support must be capability-gated: the public docs describe App Server as the integration protocol behind rich clients, but do not promise a third party can attach to an already-running Desktop task. When no attachable server is available, show read-only status/history where available and activate Codex Desktop as the safe fallback.

## Recommended Stack

### Core Framework

| Technology | Version | Purpose | Why |
|---|---:|---|---|
| Swift 6 + SwiftUI + AppKit | inherited; macOS 15.6+ | Notch UI, menu bar, windows, app activation | Reuse Claude Atoll’s existing UI, `SessionStore` actor, `AsyncStream`, accessibility onboarding, terminal focus, tmux support, and release shell. No web runtime is justified. **HIGH** |
| `CodexAppServerClient` Swift actor | App Server protocol matched to installed Codex | Thread list/read, live lifecycle events, tool items, approvals, rate limits | Official protocol exposes JSON-RPC threads, turns, approvals, and `account/rateLimits/read`. Run `codex app-server generate-json-schema` during compatibility tests and negotiate capabilities at startup; never hard-code a schema copied from a different CLI release. **HIGH** |
| `CodexCLIHookHelper` embedded Swift executable target | bundled with the app | Trusted CLI-hook bridge and synchronous approval relay | Codex lifecycle hooks are a supported integration surface and `PermissionRequest` accepts an allow/deny JSON response. A small signed Swift helper avoids Claude Atoll’s Python 3.14/`uv` runtime dependency. **HIGH** |
| `CodexSessionAdapter` / `CodexDesktopAdapter` | project code | Normalize CLI, App Server, and Desktop records into the existing session model | Keep provider-specific protocol code out of `SessionStore`; source label and capabilities belong on the normalized record. This is the one necessary new abstraction because CLI and Desktop cannot honestly promise equal control. **HIGH** |

### Codex Integration Surfaces

| Source | Use for v1 | Direct approval | Do not assume | Confidence |
|---|---|---|---|---|
| Codex CLI hooks (`~/.codex/hooks.json` / config layers) | Real-time start, prompt, tool, compaction, stop, session-end state; terminal PID/TTY captured by helper; CLI permission UI | Yes. Keep the helper alive while forwarding `PermissionRequest`, then emit Codex’s documented `allow`/`deny` response. | That a `notify` callback covers every lifecycle event; it is only a notification command. | HIGH |
| Codex App Server | Thread enumeration, persisted history, event stream, usage, and direct approval requests delivered on Atoll’s own client connection | Yes, for requests the connected server sends to Atoll. Render only server-offered decisions and scope by `threadId`, `turnId`, and request/item id. | That all methods are stable or that Atoll can answer a request sent to another client such as an existing Desktop process. | HIGH |
| Codex Desktop | Source-labelled task list/history through an explicitly connected App Server or best-effort local persisted-thread reader; bring the Desktop app to foreground | Only when Desktop is intentionally using an App Server connection Atoll can receive requests from; otherwise "Open Codex" fallback. | A public deep link to a specific task, a public plugin API for task observation, or access to its private stdio transport. | MEDIUM |
| Local `$CODEX_HOME/sessions/**/*.jsonl` and state DB | Read-only repair/fallback for persisted conversation data when App Server is absent | No | Stable filename, payload, or database schema. Version it behind one parser and degrade without data loss. | MEDIUM |

### Existing Dependencies to Retain

| Library | Version policy | Purpose | When to use |
|---|---|---|---|
| Sparkle | 2.x, pin resolved version | Signed in-app updates | Retain for public releases; configure an EdDSA-signed appcast. |
| swift-markdown | 0.5.x, pin resolved version | Render message/tool history | Retain for the existing chat view. |
| swift-subprocess | 0.4.x, pin resolved version | Run `codex`, `tmux`, and release helpers without blocking UI | Retain where Claude Atoll already uses it; do not add another process wrapper. |
| OcclusionKit | fixed release or commit, not `main` | Notch/window occlusion behavior | Retain, but replace the floating `main` branch requirement with a reproducible pin before release. |
| Foundation / Network / Darwin | OS-provided | JSONL parsing, file watching, Unix socket, process discovery | Use before adding a socket, JSON-RPC, file-watcher, or database dependency. |

### Distribution Infrastructure

| Technology | Purpose | Why |
|---|---|---|
| Developer ID Application signing + hardened runtime + notarization | Public DMG trust | Claude Atoll’s ad-hoc/not-notarized release flow is not sufficient for the requested public release. Sign the app, embedded hook helper, Sparkle framework, and DMG consistently. |
| Sparkle EdDSA appcast | Verified automatic updates | Required alongside a public DMG; do not ship update URLs without signatures. |
| Per-user runtime directory and authenticated Unix socket | IPC trust boundary | Put the socket and a generated capability token in a user-only application-support directory (0700 parent, 0600 token/socket). Validate peer/token and expire pending approval requests. Do not retain the inherited predictable `/tmp/claude-atoll.sock` design. |

## Component Reuse and Required Changes

| Reuse unchanged or near-unchanged | Replace / add |
|---|---|
| `NotchView`, menu bar/UI layout, `SessionPhase`, `SessionStore` actor/stream pattern, `ClaudeSessionMonitor` lifecycle shape, `ChatHistoryManager`, `TerminalFocuser`, tmux/window helpers, Sparkle driver, onboarding shell | Rename Claude models; introduce source/capability fields; replace `HookInstaller`, Python bridge, hook event payload, JSONL parser, OAuth quota tracker, and Claude-only approval/tmux assumptions with Codex adapters. |

Preserve `TerminalFocuser` for CLI: hooks can associate a turn with a helper-observed PID/TTY and its parent terminal. For Desktop, use `NSRunningApplication.activate()` to focus the application only; do not try to script a conversation selection through Accessibility APIs.

## Approval Implementation Rule

1. **CLI:** a trusted `PermissionRequest` hook sends the request to Atoll and waits only for the documented bounded timeout. Atoll returns `allow` or `deny`; timeout/socket failure returns no decision so Codex shows its native prompt.
2. **App Server:** respond through the same JSON-RPC request channel using only `availableDecisions`; await `serverRequest/resolved`/completed item before updating the UI.
3. **Desktop without an owned connection:** never inject keystrokes or use UI automation. Mark direct approval unavailable and offer “Open Codex”.

This honors the project’s gradual-degradation decision and prevents a public app from granting an approval it cannot prove it owns.

## Alternatives Considered

| Category | Recommended | Alternative | Why not |
|---|---|---|---|
| CLI events | Codex hooks + signed embedded helper | Poll terminal output / scrape TUI | Hooks carry lifecycle and permission context; terminal parsing is brittle and cannot safely respond to approvals. |
| Structured data | App Server JSON-RPC | Parse only JSONL/SQLite | App Server officially exposes threads, history, approvals, and rate limits; local storage is an implementation detail. |
| Desktop action | App Server when explicitly connected; otherwise foreground app | Accessibility keystrokes / process injection | No safe public contract for task-level control; forbidden by project scope. |
| Usage | `account/rateLimits/read` and update notifications | Keychain OAuth extraction + private HTTP endpoint | The official protocol returns rate-limit windows; token scraping creates an unnecessary privacy and support burden. |
| Hook runtime | Embedded Swift helper | Python + `uv` as in Claude Atoll | A public DMG should not require a separately installed interpreter or package runner. |
| Cross-platform shell | Keep native macOS app | Electron/Node companion | Adds a large runtime without solving Codex integration; macOS is intentionally the only v1 target. |

## Installation / Compatibility Checks

```bash
# Build the app and its signed embedded Codex hook helper
xcodebuild -scheme CodexAtoll -configuration Release build

# Generate the App Server schema from the installed Codex version for CI fixtures
codex app-server generate-json-schema --out .build/codex-app-server-schema

# Verify the integration surfaces present on the user's machine
codex --version
codex app-server --help
```

At launch, detect the CLI version and probe the App Server with `initialize`; present a disabled capability with a clear reason instead of inferring support from the version number. The app should install or merge only its uniquely marked hook entries, preserve all existing user/project hooks, and require Codex’s normal trust confirmation rather than bypassing it.

## Sources

- [Official Codex Hooks documentation](https://developers.openai.com/codex/hooks) — lifecycle events, trusted command hooks, and synchronous `PermissionRequest` decisions. **HIGH**
- [Official Codex App Server documentation](https://developers.openai.com/codex/app-server) — JSON-RPC client lifecycle, threads/history, approvals, rate limits, and experimental capability gates. **HIGH**
- [OpenAI Codex App Server implementation README](https://github.com/openai/codex/blob/main/codex-rs/app-server/README.md) — transports and version-matched schema generation. **HIGH**
- [OpenAI Codex app-server daemon README](https://github.com/openai/codex/blob/main/codex-rs/app-server-daemon/README.md) — daemon relationship to desktop/mobile remote clients; experimental lifecycle caveat. **HIGH**
- Local inspection: Codex CLI `0.147.0` exposes `app-server`, `remote-control`, `mcp-server`, and schema generation; local session logs are JSONL under `$CODEX_HOME/sessions`. This supports the fallback recommendation but is not a public compatibility contract. **MEDIUM**
