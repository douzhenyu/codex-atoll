# Phase 1: Honest Desktop Companion - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-08-17
**Phase:** 1-honest-desktop-companion
**Areas discussed:** Desktop entry presentation, capability boundary presentation, usage entry and detail, privacy disclosure

---

## Desktop Entry Presentation

| Decision | Alternatives considered | Selected |
|----------|-------------------------|----------|
| Collapsed entry | Icon/source badge; persistent shortcut; expanded only | Codex icon left, compact state right, no shortcut |
| Auto-expand events | Blocking interactions; blocking plus errors; all state changes | Blocking interactions only |
| No-interaction behavior | Wait for interaction; fixed timeout; remain until resolved | Fixed timeout |
| Retract timing | 5s + 300ms; 3s + immediate; 10s + 1s | 5s + 300ms |

**User's choice:** Default collapsed; blocking interactions expand automatically; retract after five seconds without interaction and 300 ms after pointer and keyboard focus leave.

**Notes:** Loading animation is valid only for observable or Atoll-owned sessions. Phase 1 Desktop status remains explicitly unobservable.

---

## Capability Boundary Presentation

| Decision | Alternatives considered | Selected |
|----------|-------------------------|----------|
| Visual label | Text + icon; color/icon only; grouped regions | Text + icon |
| Label scope | Per action; whole card; weakest capability | Whole card |
| Mixed capabilities | Split cards; classify by primary capability; dual labels | Split cards |
| Unobservable state | Explanation + jump; disabled skeleton; hidden | Explanation + Open ChatGPT |

**User's choice:** `Available` means direct in-notch interaction; `Jump only` opens an external detail surface; `Currently unobservable` means current Codex runtime information cannot be obtained.

**Notes:** Whole-card capability labels require separate cards for mixed behavior.

---

## Usage Entry and Detail

| Decision | Alternatives considered | Selected |
|----------|-------------------------|----------|
| Compact summary | Remaining + reset; remaining only; used amount | Remaining + reset |
| Detail composition | Quota cards + heatmap; heatmap first; cards only | Quota cards + 30-day heatmap |
| Detail location | In-notch; popover; separate window | In-notch |
| Trust signal | Source + update time; source only; refresh animation | Source + update time |

**User's choice:** Put a compact usage summary at the top left of the expanded notch and switch in place to detailed quota cards and a heatmap.

**Notes:** Phase 1 must show an honest unavailable state and official handoff until a supported authoritative data source exists.

---

## Privacy Disclosure

| Option | Description | Selected |
|--------|-------------|----------|
| Accept recommendation | Integration-specific disclosure, off-by-default consent, revocation, deletion, and hard credential/private-data exclusions | ✓ |
| Adjust recommendation | User supplies alternate disclosure behavior | |

**User's choice:** Accepted the recommended privacy scheme.

**Notes:** No generic first-launch blocker; disclosure occurs immediately before each integration is enabled and remains reviewable later.

## Claude's Discretion

- Privacy page layout, iconography, and concise copy, within the accepted disclosure and safety contract.

## Deferred Ideas

- Direct commands, choices, pause, approvals, and live loading states for officially observable or Atoll-owned sessions.
- Account-wide quota and usage heatmap activation when an official supported data source becomes available.
