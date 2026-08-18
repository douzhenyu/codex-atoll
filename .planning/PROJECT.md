# Codex Atoll

## What This Is

Codex Atoll is a macOS notch and menu-bar companion for OpenAI Codex. It gives Mac users one place to monitor Codex CLI sessions and Codex Desktop tasks, inspect their history, and act when a task needs attention without repeatedly switching windows.

The project starts from the Apache-2.0-licensed Claude Atoll codebase and adapts its mature notch UI, window management, session state model, and release infrastructure to Codex-specific integrations.

## Core Value

Codex users can notice and handle tasks that need attention without interrupting their current workflow.

## Requirements

### Validated

- ✓ Users can see a source-labelled Codex Desktop entry whose unavailable capabilities are explicit — Phase 1
- ✓ Users can activate ChatGPT Desktop through a fixed native handoff without a task-focus claim — Phase 1
- ✓ Users can open the official Codex usage page without Codex Atoll reading credentials or quota data — Phase 1
- ✓ Users can review the complete pre-enable data boundary and credential exclusions — Phase 1

### Active

- [ ] Users can see Codex CLI sessions and Codex Desktop tasks in one source-labelled interface.
- [ ] Users can distinguish running, waiting, completed, and failed work at a glance.
- [ ] Users can open or focus the terminal or Desktop task associated with an item.
- [ ] Users can inspect conversation messages, tool calls, and tool results when Codex exposes them.
- [ ] Users can approve or deny tool execution directly when a stable, safe integration exists.
- [ ] Users get a clear one-click fallback to the originating session when direct approval is unavailable.
- [ ] Users can install a public release from a DMG with onboarding, update support, and basic documentation.

### Out of Scope

- Forcing approval through brittle UI automation or process injection — unsupported integrations must degrade to focusing the originating session.
- Rewriting working Claude Atoll UI and macOS infrastructure without a Codex-specific reason — reuse keeps the port focused and maintainable.
- Supporting non-macOS platforms in v1 — the product is built around macOS notch, window, accessibility, and menu-bar APIs.
- Guaranteeing data that Codex does not expose through a stable local or official interface — surface capability limits honestly instead.

## Context

- The reference project is `/Users/dou/claude-atoll`, a Swift 6 macOS application targeting macOS 15.6+.
- Claude Atoll receives Claude Code hook events through a bundled Python bridge and Unix socket, keeps session state in a Swift actor, reads JSONL conversation history, and presents it through SwiftUI/AppKit.
- Codex Atoll must determine separate, supportable integration paths for Codex CLI and Codex Desktop, then normalize both into a shared session model.
- The intended audience is macOS users who run Codex from both terminals and the Desktop app and want a publicly installable companion rather than a private prototype.
- v1 aims for feature completeness across status, navigation, history, approvals, and usage, with graceful degradation where Codex lacks a stable API.

## Constraints

- **Reference implementation**: Start from Claude Atoll and preserve its Apache-2.0 attribution and notices — reuse is the fastest path to a dependable macOS experience.
- **Compatibility**: Support both Codex CLI and Codex Desktop in v1 — neither source is an optional follow-up.
- **Integration safety**: Prefer official or stable local interfaces; do not depend on fragile UI scripting for direct approvals — public releases must fail safely as Codex evolves.
- **Distribution**: v1 must be suitable for public DMG distribution with onboarding, basic documentation, and an update path.
- **Platform**: macOS first, with the inherited SwiftUI/AppKit architecture and deployment baseline reviewed during technical research.
- **Capability honesty**: History, approval, and quota features may differ by source; the UI must make unavailable capabilities and fallback behavior explicit.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Fork and adapt Claude Atoll rather than reimplementing it | The reference already solves the macOS notch, windowing, state, and release problems | ✓ Phase 1 preserved Apache attribution and selectively reused the native shell without inherited services |
| Support Codex CLI and Codex Desktop from the first public release | The product should provide one attention surface across both primary Codex workflows | — Pending |
| Include status, navigation, history, approvals, and usage in v1 | A notification-only clone would not deliver the requested complete companion experience | — Pending |
| Gracefully fall back to focusing the original session when direct approval is unavailable | Stable and safe integrations matter more than simulated feature parity | ✓ Phase 1 validated the activation-only Desktop fallback |
| Target a public release rather than a source-only prototype | Installability, onboarding, updates, and documentation are part of the requested definition of done | — Pending |
| Treat Codex Desktop as currently unobservable until a public interface exists | App presence cannot prove task state, history, control, or approval capability | ✓ Phase 1 ships one honest source-labelled card with no inferred lifecycle |
| Keep usage outside the app until an authoritative provider exists | Scraping account pages or credentials would create fragile privacy risk | ✓ Phase 1 opens only the fixed official usage URL |
| Keep all integrations disabled while presenting the future data boundary | Users should understand prompt, tool, result, session, location, and retention handling before consent | ✓ Phase 1 ships an always-accessible static disclosure |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-08-18 after Phase 1*
