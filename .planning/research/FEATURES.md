# Feature Landscape

**Domain:** macOS notch and menu-bar companion for Codex CLI and ChatGPT Desktop Codex
**Researched:** 2026-08-17
**Confidence:** MEDIUM — current official Codex CLI, Hooks, App Server, Desktop, permission, and usage documentation was checked. Desktop has no documented third-party session API in the reviewed material, so its negative capability claims are intentionally scoped to the public interface.

## Capability Matrix

The product needs one visual model, but not false feature parity. A source label and an explicit `Available`, `Open original`, or `Unavailable` capability state are table stakes on every session detail view.

| User behavior | Codex CLI: supportable v1 path | Codex Desktop: supportable v1 path | Product decision |
|---|---|---|---|
| Discover live work | Install cooperative `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, `Stop`, and `SessionEnd` hooks, then stream the normalized payload to the app. | No documented public event feed for another app. Detect only that the ChatGPT app is running and offer an explicit user-created/opened Desktop task reference. | CLI is live; Desktop is a source-labelled shell until an official integration exists. |
| Show status | Derive running, needs approval, waiting for user, completed, interrupted, and failed from hooks; reconcile final state from hook events. | `Open ChatGPT` only; do not infer status from pixels, accessibility text, logs, or private databases. | Never show invented Desktop status. |
| Open original work | Focus terminal via recorded PID/TTY/window identity, with a project/title fallback. | Activate ChatGPT; if a supported deep link is later documented, use it behind a capability check. | Both sources must always have an escape hatch to the original UI. |
| Inspect messages/tools/results | Show live hook payloads plus in-memory event trail. App Server can provide full item and turn history only for threads the companion itself owns. `transcript_path` is explicitly not a stable hook contract. | No documented third-party history read interface. | CLI: live activity is required; full persisted history is owned-App-Server-only. Desktop: show no history rather than scrape private storage. |
| Approve or deny | A synchronous `PermissionRequest` hook can relay a single decision to Atoll and return `allow`, `deny`, or no decision. App Server offers structured approval requests for Atoll-owned threads. | The Desktop app has user approval modes but no documented external approval endpoint. | Direct approval is CLI-only and must fail safely; Desktop action is `Open in ChatGPT`. |
| Usage/quota | Show a neutral “Open Codex usage” action and latest local availability state only. OpenAI documents plan-dependent shared agentic limits, not a public local quota API. | Same account-level action. | Do not read Keychain credentials or call undocumented usage endpoints. |

## Table Stakes

Features users need before a notch companion is trustworthy.

| Feature | Why Expected | Complexity | Dependencies and testable acceptance | Fallback behavior |
|---|---|---|---|---|
| Source-labelled unified task list | Users asked for CLI and Desktop in one place; identity must be unambiguous. | Med | Every card has `CLI` or `Desktop`, title, project/workspace where known, and last update. Selecting it never changes the original task. | Unknown source is not listed as Codex work. |
| Honest attention states | A notifier must separate active work from a request that blocks progress. | Med | CLI renders `running`, `needs approval`, `needs input`, `completed`, `interrupted`, `failed`; each transition is driven by an official hook or App Server event. Desktop displays only `Open ChatGPT` / `not observable`, never a guessed lifecycle. | State changes to `connection lost` after a bounded bridge timeout. |
| One-click return to origin | The core value is avoiding window hunting. | Med | Clicking a CLI card focuses its terminal when identity is known; clicking a Desktop card activates ChatGPT. Both show a visible error if focus fails. | Copy project/session reference and use generic app activation. |
| Approval review with safe response (CLI) | Users need to inspect command/tool, reason, paths, and requested scope before acting. | High | Given a CLI `PermissionRequest`, Atoll shows the exact hook payload; `Allow once`/`Deny` return only one decision to the still-live hook and the terminal moves forward accordingly. The bridge is authenticated, has a short timeout, and does not retain a reusable approval token. | On timeout, disconnect, stale request, or unknown decision: return no decision so Codex keeps its native approval flow, then focus the terminal. |
| Native-approval handoff (Desktop) | Desktop users still need a reliable response path. | Low | Every Desktop “needs review” affordance, if a future official signal exists, activates ChatGPT and explains that approval stays there. | Default Desktop action is simply `Open ChatGPT`; no direct controls are shown. |
| Recent activity detail | Users expect enough context to decide whether to switch. | Med | CLI detail shows normalized user prompt summary, tool started/completed/failure, final result, timestamps, and redaction status. It only promises an event trail captured while Atoll was connected. | Explain “history not available for this source/session,” rather than display stale or scraped data. |
| Privacy and configuration control | Hooks observe prompts, commands, tool input, and results, so consent cannot be buried. | Med | Onboarding lists event data, local socket scope, retention period, and each config file changed; disable removes only Atoll-owned hook entries. | Monitoring off means no captured history/notifications. |
| Onboarding, DMG, update path, and docs | Public distribution is a stated release requirement. | Med | Fresh install can grant necessary macOS permissions, opt into CLI hook installation after preview, open sample setup docs, check updates, and cleanly uninstall integration. | The app remains usable as a launcher/status shell with monitoring disabled. |
| Usage entry point | Users explicitly requested quota visibility. | Low | Selecting usage launches the official Codex usage/limit surface; UI states it is plan-wide and may be unavailable. | Never estimate quota from tokens or credentials. |

## Differentiators

Features worth building once the trustworthy baseline is in place.

| Feature | Value Proposition | Complexity | Notes |
|---|---|---|---|
| Capability-aware unified UI | One notch handles both sources without pretending they expose the same controls. | Med | Per-card capabilities (`live`, `history`, `approve`, `open`) make degradation self-explanatory. |
| Approval safety preview | Show command, cwd, side-effect class, file/network scope, and the exact approval lifespan before the user commits. | High | Prefer `Allow once`; session-scoped permissions require a second deliberate action. Network requests must be rendered as host/protocol, not a misleading shell command. |
| App-Server-owned sessions | When a user starts a Codex session from Atoll, App Server supplies structured status, item deltas, stored-turn history, approvals, and user-input requests. | High | This is a separate launch mode, not a claim that Atoll can attach to arbitrary existing CLI or Desktop sessions. |
| Cross-source attention queue | Sort by blocking urgency: live CLI approvals/input first, then active CLI, then Desktop launch shortcuts. | Low | Keep source badge visible in every compact state. |
| Local-first redaction and expiry | Store the minimum event trail locally, redact secrets before persistence, make retention user-configurable, and offer a one-click clear. | Med | The UI should distinguish live-only data from persisted activity. |
| Diagnostics screen | Explain hook version, bridge health, last event, monitoring permissions, app version, and unavailable source capabilities. | Med | This will materially reduce support burden for a public DMG. |

## Anti-Features

Features to explicitly not build in v1.

| Anti-Feature | Why Avoid | What to Do Instead |
|---|---|---|
| UI automation, accessibility scraping, process injection, or private-store parsing for Desktop task status/history/approval | These are brittle, violate the project safety boundary, and could make a stale UI authorize the wrong action. | Activate ChatGPT and let it retain control; add richer Desktop behavior only when OpenAI publishes an integration surface. |
| Claiming full conversation history from CLI transcript files | Hooks documentation marks `transcript_path` as a convenience whose format is not stable. | Display captured live event history; provide full history only for companion-owned App Server threads. |
| Keychain/OAuth scraping or undocumented usage API calls | Account credentials and quota endpoints are a sensitive, unstable boundary. | Link to the official usage page/limit banner and show no fabricated remaining-credit figure. |
| Persistent “approve all” or automatic approval by default | It destroys the product’s safety promise and can outlive the context the user reviewed. | Offer only request-scoped decisions by default; make any session scope explicit and reflect Codex’s available decisions. |
| Replacing the terminal or ChatGPT Desktop conversation editor | It expands into a second Codex client and risks session divergence. | Keep Atoll an attention, context, decision, and navigation surface. |
| Generic “Codex is working” notification based on process polling | It cannot distinguish a process from an active task and causes false attention signals. | Use lifecycle hooks/App Server events, or show no state. |

## Feature Dependencies

```text
Consent + safe configuration merge
  -> authenticated CLI hook bridge
  -> normalized CLI lifecycle state
  -> attention queue, notifications, terminal focus, live activity detail
  -> request-scoped CLI approval

App Server launch ownership
  -> structured item/turn history + structured approvals + user-input routing

ChatGPT Desktop app activation
  -> Desktop-labelled launch/reference card
  -> richer Desktop monitoring only after an official public integration exists

Official usage page access
  -> usage entry point (not a local remaining-quota meter)

Notch/menu-bar shell + onboarding + release/update infrastructure
  -> public DMG release
```

## MVP Recommendation

Prioritize:

1. **Capability contract and source-labelled shell.** Build the shared card/state model with a truthful CLI/Desktop capability matrix and universal focus actions.
2. **Cooperative Codex CLI integration.** Install/merge only Atoll-owned hooks, receive lifecycle data over an authenticated local bridge, then deliver accurate state, alerts, terminal focus, and live activity detail.
3. **Safe CLI approval handoff.** Relay synchronous `PermissionRequest` decisions with bounded waits; default every failure to the native terminal prompt. Add an Atoll-owned App Server launch mode only after the hook flow is validated.
4. **Public-release baseline.** Privacy-first onboarding, removable integration, diagnostics, DMG/update pipeline, docs, and official-usage navigation.
5. **Desktop support with explicit degradation.** Ship ChatGPT activation and labelled reference cards; do not promise live status, history, or direct approval until an official Desktop integration is available and validated.

Defer: arbitrary existing CLI full-history import and all Desktop monitoring/approval. They require a stable interface that the current public documentation does not establish.

## Phase Research Flags

| Topic | Status | What must be proven before committing implementation |
|---|---|---|
| CLI hook bridge | Needs a spike | Exact hook config merge behavior, command-hook timeout/cancellation, local socket authentication, concurrent approvals, and no-decision fallback on current Codex versions. |
| App Server launch mode | Needs a spike | Whether app-server can coexist with the desired terminal UX; schema/version negotiation; what counts as an Atoll-owned session. |
| CLI terminal focusing | Standard macOS work | PID/TTY/tmux/window matching across Terminal, iTerm2, Warp, and a no-permission fallback. |
| ChatGPT Desktop integration | Blocked pending public surface | Confirm an official deep link, task/event API, or supported plugin path. Do not substitute reverse-engineering or UI automation. |
| Usage | Standard, constrained | Link to official account usage; do not implement a numeric meter without an official supported endpoint. |

## Sources

- [Codex Hooks](https://learn.chatgpt.com/docs/hooks) — MEDIUM, official current documentation; lifecycle events, `PermissionRequest` decisions, and transcript stability limit.
- [Codex App Server](https://learn.chatgpt.com/docs/app-server) — MEDIUM, official current documentation; owned-thread events, history reads, user input, and structured approvals.
- [Codex CLI](https://learn.chatgpt.com/docs/codex/cli) — MEDIUM, official current documentation; CLI scope and saved-session resume.
- [Permissions](https://learn.chatgpt.com/docs/permission-modes) — MEDIUM, official current documentation; Desktop/CLI permission behavior and the original UI’s role.
- [ChatGPT desktop app](https://learn.chatgpt.com/docs/app) — MEDIUM, official current documentation; desktop product scope. The absence of an external task API is a bounded finding from reviewed public docs, not a claim about private implementation.
- [Using Codex with your ChatGPT plan](https://help.openai.com/en/articles/11369540/) — MEDIUM, official current documentation; plan-dependent shared Codex limits and official usage-page guidance.
- [Feature maturity labels](https://learn.chatgpt.com/docs/feature-maturity) — MEDIUM, official current documentation; release decisions should exclude experimental interfaces from a public v1 unless explicitly gated.
