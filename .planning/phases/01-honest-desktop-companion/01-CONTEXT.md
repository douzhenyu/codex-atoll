# Phase 1: Honest Desktop Companion - Context

**Gathered:** 2026-08-17
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver the truthful Desktop-facing notch shell: a source-labelled Codex Desktop entry, ChatGPT activation, an official usage/limits handoff, and a reviewable privacy boundary. Phase 1 must not claim live Desktop task state, history, approvals, account-wide quota, or usage history when no official verifiable source exists.

</domain>

<decisions>
## Implementation Decisions

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

### Claude's Discretion
- Exact privacy-page layout, iconography, and concise copy may be chosen during UI design, provided D-12 through D-16 remain explicit and testable.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Product and Scope
- `.planning/PROJECT.md` — Product identity, goals, constraints, and explicit safety boundaries.
- `.planning/ROADMAP.md` — Phase 1 goal, requirements, and success criteria; live CLI and owned-session controls remain in later phases.
- `.planning/REQUIREMENTS.md` — Authoritative DESK-01 through DESK-03, USAGE-01, PRIV-01, and PRIV-05 contracts, plus deferred DESK-04 through DESK-07 and USAGE-03.

### Technical Research
- `.planning/research/SUMMARY.md` — Consolidated stack, architecture, and boundary findings.
- `.planning/research/FEATURES.md` — Official capability findings and the distinction between Desktop handoff and observable CLI/App Server sessions.
- `.planning/research/ARCHITECTURE.md` — Recommended SwiftUI/AppKit boundaries and integration sequencing.
- `.planning/research/PITFALLS.md` — Failure modes around private APIs, credential access, misleading state, and inherited Claude behavior.
- `.planning/research/STACK.md` — macOS implementation stack and dependency guidance.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `/Users/dou/claude-atoll/ClaudeAtoll/App/ClaudeAtollApp.swift`: reuse the SwiftUI/AppKit application shell pattern.
- `/Users/dou/claude-atoll/ClaudeAtoll/App/AppDelegate.swift`: reuse lifecycle and window setup, but remove automatic Claude hook installation.
- `/Users/dou/claude-atoll/ClaudeAtoll/UI/Views/NotchView.swift`: reuse the notch geometry and expansion shell, replacing Claude-specific monitoring content.
- `/Users/dou/claude-atoll/ClaudeAtoll/UI/Views/NotchMenuView.swift`: reuse menu-row and `NSWorkspace.shared.open` patterns for ChatGPT, official usage, and privacy actions.
- `/Users/dou/claude-atoll/ClaudeAtoll/Core/Modules/ModuleRegistry.swift` and `ModuleLayoutConfig.swift`: reuse the modular placement model for source-labelled cards and the usage summary.

### Established Patterns
- Preserve the SwiftUI/AppKit hybrid and existing notch interaction model rather than introducing a new UI framework.
- Reuse `@AppStorage`/`UserDefaults` only for non-sensitive preferences and disclosure state.
- Use `NSWorkspace.shared.open` for ChatGPT activation and official web handoffs.

### Integration Points
- Replace Claude-specific session monitoring in `NotchView` with a truthful Codex Desktop companion card.
- Replace Claude hook/token settings in `NotchMenuView` with Desktop, usage, and privacy entries.
- Do not reuse Claude token tracking, OAuth/Keychain reads, private usage endpoints, or unconditional hook installation.

</code_context>

<specifics>
## Specific Ideas

- The collapsed presentation should read as a quiet Codex presence: icon on the left, trustworthy compact state on the right.
- The expanded surface should keep usage visible at top left and allow an in-place transition to details.
- Capability labels describe whole cards, so card splitting is preferred over per-button exceptions.

</specifics>

<deferred>
## Deferred Ideas

- Live loading states, automatic expansion for approval/input, in-notch commands, choices, pause, and approval belong to Phases 2–4, where Codex Atoll has an official observable or owned session.
- Authoritative account-wide remaining quota and historical heatmaps remain deferred until OpenAI exposes a supported data source; Phase 1 implements only the truthful unavailable/handoff state.

</deferred>

---

*Phase: 1-honest-desktop-companion*
*Context gathered: 2026-08-17*
