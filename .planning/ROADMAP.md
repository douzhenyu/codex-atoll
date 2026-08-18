# Roadmap: Codex Atoll

## Overview

Codex Atoll becomes a trustworthy macOS attention companion in six vertical MVP slices: first an honest Desktop and usage handoff, then secure live CLI monitoring and safe CLI actions, followed by richer Atoll-owned App Server sessions. The final slices make the experience understandable, removable, and suitable for public distribution without claiming unsupported Codex Desktop capabilities.

## Phases

**Phase Numbering:**

- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Honest Desktop Companion** - A source-labelled Desktop handoff and official usage entry point with transparent privacy boundaries.
- [ ] **Phase 2: Trusted CLI Monitoring** - Consent-based, authenticated CLI monitoring with live state, activity, notifications, and diagnostics.
- [ ] **Phase 3: Safe CLI Actions** - Verified terminal return and request-scoped approval decisions with native fallback.
- [ ] **Phase 4: Atoll-Owned Sessions** - Opt-in App Server sessions provide structured history, supported controls, and authoritative limits.
- [ ] **Phase 5: Guided Ownership** - Complete onboarding, documentation, and removal paths for safe day-to-day use.
- [ ] **Phase 6: Public Release Delivery** - A Gatekeeper-ready DMG and authenticated application updates.

## Phase Details

### Phase 1: Honest Desktop Companion

**Goal**: Users can use an honest Desktop companion entry and official usage handoff while understanding Codex Atoll's data boundary.
**Mode:** mvp
**Depends on**: Nothing (first phase)
**Requirements**: DESK-01, DESK-02, DESK-03, USAGE-01, PRIV-01, PRIV-05
**Success Criteria** (what must be TRUE):

  1. User can see a source-labelled Codex Desktop entry in the notch that never presents unverified status, history, or approval data.
  2. User can open ChatGPT Desktop from that entry and is told clearly which actions must remain in ChatGPT until an official integration is available.
  3. User can open the official Codex usage or limits surface without Codex Atoll requesting or reading account credentials.
  4. Before enabling any integration, user can review the prompt, tool, result, and session metadata Codex Atoll may process.

**Plans**: 3/5 plans executed

Plans:
**Wave 1**

- [x] 01-01-PLAN.md — Establish Apache attribution, Codex identity, app/XCTest targets, and the shared scheme.

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 01-02-PLAN.md — Wire the native collapsed/open notch shell and neutral local companion route.

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 01-03-PLAN.md — Add the honest Desktop capability card and bounded ChatGPT activation.

**Wave 4** *(blocked on Wave 3 completion)*

- [ ] 01-04-PLAN.md — Add the in-notch usage-unavailable route, official handoff, and accessible menu.

**Wave 5** *(blocked on Wave 4 completion)*

- [ ] 01-05-PLAN.md — Add Privacy & Data disclosure and prove the full capability/privacy boundary.

**UI hint**: yes

### Phase 2: Trusted CLI Monitoring

**Goal**: Users can safely monitor verified Codex CLI work alongside the Desktop entry, with current status, activity, and integration health.
**Mode:** mvp
**Depends on**: Phase 1
**Requirements**: CORE-01, CORE-02, CORE-03, CORE-04, CLI-01, CLI-02, CLI-03, CLI-04, CLI-05, CLI-06, CLI-07, PRIV-02, PRIV-03, PRIV-04
**Success Criteria** (what must be TRUE):

  1. User can preview and consent to the exact CLI hook configuration and captured data, install it without overwriting unrelated Codex configuration, and later remove only Codex Atoll-owned entries and helpers.
  2. User can view live Codex CLI sessions and the Codex Desktop entry together in the notch, with a source label and an accurate per-item list of available actions.
  3. User can distinguish verified CLI running, waiting for approval, waiting for input, completed, interrupted, failed, and disconnected states, including when the last update has become stale.
  4. User receives configured notch or macOS attention for CLI approval, input, and completion, and can inspect or clear a bounded local trail of captured prompts, tool activity, results, failures, and timestamps according to the selected retention mode.
  5. User can inspect hook version, bridge connection, last event, and actionable setup errors, while events and responses from outside the current user's authenticated integration are rejected.

**Plans**: TBD
**UI hint**: yes

### Phase 3: Safe CLI Actions

**Goal**: Users can return to a live CLI task and resolve only the exact, still-valid permission request that needs attention.
**Mode:** mvp
**Depends on**: Phase 2
**Requirements**: NAV-01, NAV-02, APPR-01, APPR-02, APPR-03, APPR-04
**Success Criteria** (what must be TRUE):

  1. User can focus the terminal and tmux pane for a live CLI session when sufficient identity information exists; otherwise the app explains the fallback without sending synthetic terminal input.
  2. User can review the exact live permission request, including its tool, command or action, working directory, relevant scope, and freshness.
  3. User can allow once or deny a matching, still-live request from the notch through a supported synchronous hook response, and the request becomes unavailable after resolution, expiry, disconnect, or mismatch.
  4. When a decision cannot be delivered safely, user is returned to Codex's native approval flow instead of seeing a misleading local control.

**Plans**: TBD
**UI hint**: yes

### Phase 4: Atoll-Owned Sessions

**Goal**: Users can opt into compatible Codex App Server sessions with structured context and controls that are explicitly scoped to Atoll-owned work.
**Mode:** mvp
**Depends on**: Phase 3
**Requirements**: OWN-01, OWN-02, OWN-03, OWN-04, USAGE-02
**Success Criteria** (what must be TRUE):

  1. User can start or resume a session through a locally managed Codex App Server connection only after the installed version and schema are confirmed compatible.
  2. User can inspect structured turns, messages, tool calls, and results for an Atoll-owned session without implying complete history for arbitrary CLI or Desktop work.
  3. User can respond to structured approval and user-input requests only when the negotiated App Server capability supports them.
  4. User sees unavailable controls disabled with a compatibility explanation when the installed App Server schema is unsupported.
  5. User can see rate-limit information only when an Atoll-owned connection supplies authoritative data, with its source and freshness shown.

**Plans**: TBD
**UI hint**: yes

### Phase 5: Guided Ownership

**Goal**: Users can understand, set up, troubleshoot, and completely remove Codex Atoll and its local integration.
**Mode:** mvp
**Depends on**: Phase 4
**Requirements**: REL-02, REL-04, REL-05
**Success Criteria** (what must be TRUE):

  1. User receives onboarding that covers permissions, optional CLI hooks, captured data, and the limits of Codex Desktop support before enabling those features.
  2. User can access practical usage, troubleshooting, privacy, security, attribution, and compatibility documentation from the product's support materials.
  3. User can follow documented steps to remove the app, its CLI integration, and retained local data without disturbing unrelated Codex configuration.

**Plans**: TBD
**UI hint**: yes

### Phase 6: Public Release Delivery

**Goal**: Users can install and update a publicly distributed Codex Atoll release without bypassing macOS trust protections.
**Mode:** mvp
**Depends on**: Phase 5
**Requirements**: REL-01, REL-03
**Success Criteria** (what must be TRUE):

  1. User can install a Developer ID-signed, notarized Codex Atoll DMG without bypassing Gatekeeper.
  2. User can receive and verify application updates through a Codex Atoll-owned signed Sparkle feed.

**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Honest Desktop Companion | 3/5 | In Progress|  |
| 2. Trusted CLI Monitoring | 0/TBD | Not started | - |
| 3. Safe CLI Actions | 0/TBD | Not started | - |
| 4. Atoll-Owned Sessions | 0/TBD | Not started | - |
| 5. Guided Ownership | 0/TBD | Not started | - |
| 6. Public Release Delivery | 0/TBD | Not started | - |
