# Requirements: Codex Atoll

**Defined:** 2026-08-17
**Core Value:** Codex users can notice and handle tasks that need attention without interrupting their current workflow.

## v1 Requirements

Requirements for the first public release. Each requirement maps to exactly one roadmap phase.

### Unified Experience

- [ ] **CORE-01**: User can view Codex CLI sessions and Codex Desktop entries in one notch interface with an explicit source label on every item.
- [ ] **CORE-02**: User can see which actions—live status, history, approval, and open-original—are currently available for each item.
- [ ] **CORE-03**: User can distinguish verified running, waiting for approval, waiting for input, completed, interrupted, failed, and disconnected states without inferred Desktop activity.
- [ ] **CORE-04**: User can see when an item's information was last updated and when its connection has become stale.

### Codex CLI Monitoring

- [ ] **CLI-01**: User can preview and explicitly consent to the Codex CLI hook configuration and local data captured by Codex Atoll.
- [ ] **CLI-02**: User can install Codex Atoll CLI hooks without overwriting unrelated Codex configuration or hooks.
- [ ] **CLI-03**: User can disable CLI monitoring and remove only Codex Atoll-owned hook entries and helper files.
- [ ] **CLI-04**: User can see live CLI session lifecycle and attention-state changes delivered through supported Codex hooks.
- [ ] **CLI-05**: User can inspect a bounded recent activity trail captured while Codex Atoll was connected, including prompts, tool activity, results, failures, and timestamps when exposed by hooks.
- [ ] **CLI-06**: User receives a macOS notification or notch attention state when a CLI session needs approval/input or completes, subject to their notification settings.
- [ ] **CLI-07**: User can diagnose CLI integration health, including installed hook version, bridge connection, last event, and actionable configuration errors.

### Navigation and Desktop

- [ ] **NAV-01**: User can focus the terminal and tmux pane associated with a live CLI session when Codex Atoll has sufficient identity information.
- [ ] **NAV-02**: User receives a clear fallback when exact CLI focus is unavailable, without Codex Atoll sending synthetic terminal input.
- [ ] **DESK-01**: User can see a source-labelled Codex Desktop entry that never claims unverified task status, history, or approval capability.
- [ ] **DESK-02**: User can activate ChatGPT Desktop from the notch to continue or review Desktop work.
- [ ] **DESK-03**: User can see why a Desktop capability is unavailable and that the action must be completed in ChatGPT until an official integration exists.

### Safe Approvals

- [ ] **APPR-01**: User can review the exact live CLI permission request, including tool, command or action, working directory, relevant scope, and request freshness.
- [ ] **APPR-02**: User can allow once or deny a still-live CLI permission request from the notch through a supported synchronous Codex hook response.
- [ ] **APPR-03**: User cannot act on an expired, disconnected, already-resolved, or mismatched approval request.
- [ ] **APPR-04**: User is returned to Codex's native approval flow when Codex Atoll cannot safely deliver a decision.

### Atoll-Owned Sessions

- [ ] **OWN-01**: User can opt into starting or resuming a Codex session through a locally managed, version-compatible Codex App Server connection.
- [ ] **OWN-02**: User can view structured turn, message, tool, and result history for sessions owned by Codex Atoll's App Server connection.
- [ ] **OWN-03**: User can respond to structured approval and user-input requests for an Atoll-owned session when the negotiated App Server capability supports them.
- [ ] **OWN-04**: User sees controls disabled with a compatibility explanation when the installed Codex App Server schema is unsupported.

### Usage

- [ ] **USAGE-01**: User can open the official Codex usage or limits surface from Codex Atoll without Codex Atoll reading account credentials.
- [ ] **USAGE-02**: User can see App Server rate-limit information only when a supported Atoll-owned connection returns authoritative data, with its source and freshness shown.

### Privacy and Local Security

- [ ] **PRIV-01**: User can review what prompt, tool, result, and session metadata Codex Atoll may process before enabling monitoring.
- [ ] **PRIV-02**: User can choose whether captured activity is live-only or retained locally for a bounded period.
- [ ] **PRIV-03**: User can clear retained Codex Atoll activity data from the app.
- [ ] **PRIV-04**: User's local bridge accepts events and approval responses only from the current user's authenticated Codex Atoll integration.
- [ ] **PRIV-05**: User is never asked to give Codex Atoll their Codex OAuth token, session cookie, or Keychain credential for monitoring or usage display.

### Public Release

- [ ] **REL-01**: User can install a Developer ID-signed and notarized Codex Atoll DMG without bypassing Gatekeeper.
- [ ] **REL-02**: User receives onboarding for required permissions, optional CLI hook installation, captured data, and Desktop capability limits.
- [ ] **REL-03**: User can receive and verify application updates through a Codex Atoll-owned signed Sparkle feed.
- [ ] **REL-04**: User can follow documented steps to uninstall the app and remove its CLI integration and retained data.
- [ ] **REL-05**: User can access basic usage, troubleshooting, privacy, security, attribution, and compatibility documentation.

## Future Requirements

Deferred until OpenAI publishes a stable supporting interface or the v1 integration is validated.

### Existing Session History

- **HIST-01**: User can import complete history for arbitrary existing CLI sessions through a stable documented Codex interface.

### Rich Desktop Integration

- **DESK-04**: User can discover and monitor individual existing Codex Desktop tasks through an official public event interface.
- **DESK-05**: User can navigate directly to a specific Codex Desktop task through an official deep link or task API.
- **DESK-06**: User can inspect Desktop task history through an official public history interface.
- **DESK-07**: User can respond to Desktop approvals through an official public control interface.

### Universal Usage Meter

- **USAGE-03**: User can view authoritative account-wide remaining Codex quota when OpenAI provides a supported API for it.

## Out of Scope

Explicitly excluded to protect reliability, security, and project focus.

| Feature | Reason |
|---------|--------|
| UI automation, accessibility scraping, process injection, or private-store parsing for Desktop task control | Brittle and unsafe; richer Desktop support waits for an official integration surface. |
| Parsing undocumented CLI transcript formats as a promise of complete history | The format is not a stable contract; v1 retains live captured activity and owned App Server history. |
| Keychain, OAuth token, session-cookie, or private quota-endpoint scraping | Credentials and undocumented account APIs are outside the app's trust boundary. |
| Persistent approve-all or automatic approval defaults | Approvals must remain live, visible, request-scoped, and fail back to Codex. |
| Synthetic terminal or tmux keystrokes for approval | Focus navigation is allowed; simulated security decisions are not. |
| Replacing the Codex conversation editor | Codex Atoll is an attention, context, decision, and navigation companion, not another Codex client. |
| Non-macOS clients | v1 depends on macOS notch, window, notification, signing, and menu-bar APIs. |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| CORE-01 | Phase 2 | Pending |
| CORE-02 | Phase 2 | Pending |
| CORE-03 | Phase 2 | Pending |
| CORE-04 | Phase 2 | Pending |
| CLI-01 | Phase 2 | Pending |
| CLI-02 | Phase 2 | Pending |
| CLI-03 | Phase 2 | Pending |
| CLI-04 | Phase 2 | Pending |
| CLI-05 | Phase 2 | Pending |
| CLI-06 | Phase 2 | Pending |
| CLI-07 | Phase 2 | Pending |
| NAV-01 | Phase 3 | Pending |
| NAV-02 | Phase 3 | Pending |
| DESK-01 | Phase 1 | Pending |
| DESK-02 | Phase 1 | Pending |
| DESK-03 | Phase 1 | Pending |
| APPR-01 | Phase 3 | Pending |
| APPR-02 | Phase 3 | Pending |
| APPR-03 | Phase 3 | Pending |
| APPR-04 | Phase 3 | Pending |
| OWN-01 | Phase 4 | Pending |
| OWN-02 | Phase 4 | Pending |
| OWN-03 | Phase 4 | Pending |
| OWN-04 | Phase 4 | Pending |
| USAGE-01 | Phase 1 | Pending |
| USAGE-02 | Phase 4 | Pending |
| PRIV-01 | Phase 1 | Pending |
| PRIV-02 | Phase 2 | Pending |
| PRIV-03 | Phase 2 | Pending |
| PRIV-04 | Phase 2 | Pending |
| PRIV-05 | Phase 1 | Pending |
| REL-01 | Phase 6 | Pending |
| REL-02 | Phase 5 | Pending |
| REL-03 | Phase 6 | Pending |
| REL-04 | Phase 5 | Pending |
| REL-05 | Phase 5 | Pending |

**Coverage:**
- v1 requirements: 36 total
- Mapped to phases: 36
- Unmapped: 0 ✓

---
*Requirements defined: 2026-08-17*
*Last updated: 2026-08-17 after project research*
