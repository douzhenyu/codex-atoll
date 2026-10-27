<!-- GSD:project-start source:PROJECT.md -->

## Project

**Codex Atoll**

Codex Atoll is a macOS notch and menu-bar companion for OpenAI Codex. It gives Mac users one place to monitor Codex CLI sessions and Codex Desktop tasks, inspect their history, and act when a task needs attention without repeatedly switching windows.

The project starts from the Apache-2.0-licensed Claude Atoll codebase and adapts its mature notch UI, window management, session state model, and release infrastructure to Codex-specific integrations.

**Core Value:** Codex users can notice and handle tasks that need attention without interrupting their current workflow.

### Constraints

- **Reference implementation**: Start from Claude Atoll and preserve its Apache-2.0 attribution and notices — reuse is the fastest path to a dependable macOS experience.
- **Compatibility**: Support both Codex CLI and Codex Desktop in v1 — neither source is an optional follow-up.
- **Integration safety**: Prefer official or stable local interfaces; do not depend on fragile UI scripting for direct approvals — public releases must fail safely as Codex evolves.
- **Distribution**: v1 must be suitable for public DMG distribution with onboarding, basic documentation, and an update path.
- **Platform**: macOS first, with the inherited SwiftUI/AppKit architecture and deployment baseline reviewed during technical research.
- **Capability honesty**: History, approval, and quota features may differ by source; the UI must make unavailable capabilities and fallback behavior explicit.

<!-- GSD:project-end -->

<!-- GSD:stack-start source:research/STACK.md -->

## Technology Stack

## Recommendation

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

## Approval Implementation Rule

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

# Build the app and its signed embedded Codex hook helper

# Generate the App Server schema from the installed Codex version for CI fixtures

# Verify the integration surfaces present on the user's machine

## Sources

- [Official Codex Hooks documentation](https://developers.openai.com/codex/hooks) — lifecycle events, trusted command hooks, and synchronous `PermissionRequest` decisions. **HIGH**
- [Official Codex App Server documentation](https://developers.openai.com/codex/app-server) — JSON-RPC client lifecycle, threads/history, approvals, rate limits, and experimental capability gates. **HIGH**
- [OpenAI Codex App Server implementation README](https://github.com/openai/codex/blob/main/codex-rs/app-server/README.md) — transports and version-matched schema generation. **HIGH**
- [OpenAI Codex app-server daemon README](https://github.com/openai/codex/blob/main/codex-rs/app-server-daemon/README.md) — daemon relationship to desktop/mobile remote clients; experimental lifecycle caveat. **HIGH**
- Local inspection: Codex CLI `0.147.0` exposes `app-server`, `remote-control`, `mcp-server`, and schema generation; local session logs are JSONL under `$CODEX_HOME/sessions`. This supports the fallback recommendation but is not a public compatibility contract. **MEDIUM**

<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->

## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->

## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->

## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->

## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:

- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->

<!-- GSD:profile-start -->

## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->

## Workspace Skills (mp-*)

This repo's agents use 12 workspace skills imported from
[mattpocock/skills](https://github.com/mattpocock/skills), renamed with an `mp-`
prefix. The rename exists because the same skills are also installed under
`~/.agents/skills/`, and an identically named local skill shadows the workspace
copy without any error.

**Updating:** `multica skill refresh <id>` re-downloads the upstream copy and
replaces the skill's name, description, content, and supporting files with
whatever upstream now has — including any invocation restriction the upstream
frontmatter carries. It preserves the skill ID and its agent bindings, and it
reports success either way. After a refresh the skill is back under its upstream
name, so the local copy shadows it again until you restore the prefix. Refresh
requires the skill's creator or a workspace owner/admin.

Update the existing `mp-*` record by ID. Re-import is the wrong tool here:
`import --on-conflict overwrite` matches on the upstream name, and no record in
this workspace carries that name any more, so it creates a second skill and
leaves the bound one untouched.

1. `multica skill refresh <existing mp-* id>`
2. Rewrite the skill so frontmatter reads `name: mp-<name>` and carries no
   `disable-model-invocation` line, then run
   `multica skill update <id> --name mp-<name> --content-file <file>`
3. Read the skill back with `multica skill get <id> --with-content` and confirm
   the stored name and content are the ones you wrote. Then run
   `multica agent skills list <agent-id>` and confirm the same ID is still
   bound.

**Verifying:** confirm the workspace copy actually loaded. The check differs by
runtime.

- **Claude runtime:** call the skill and read the `Base directory` it reports. A
  path under `<task>/workdir/.claude/skills/mp-*` means the workspace copy
  loaded. A path under `~/.claude/skills/` or `~/.agents/skills/` means the local
  copy won.
- **Codex runtime:** a skill call returns no `Base directory`; Codex reads the
  path listed in its skill list. Confirm that listed path is under
  `<task>/codex-home/skills/mp-*`. Note that `codex-home` sits beside `workdir`,
  not inside it. When the path alone is not decisive, compare the `SKILL.md`
  content hash against the workspace copy returned by
  `multica skill get <id> --with-content`.
