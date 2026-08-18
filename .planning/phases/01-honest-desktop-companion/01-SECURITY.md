---
phase: 01
slug: honest-desktop-companion
status: verified
threats_open: 0
asvs_level: 1
created: 2026-08-18
---

# Phase 01 — Security

> Phase 1 security contract reconstructed from the five plan-time threat models and their execution summaries.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| Claude Atoll reference → Codex Atoll | Only attributed native UI/project patterns enter the target; inherited identity and privileged services are rejected. | Apache provenance and selected source patterns |
| Xcode project → app process | Target membership admits one app and one XCTest target, without helper, hook, server, updater, or automation targets. | Executable code and bundled resources |
| Local UI state → user | Closed/open routes and capability labels describe only local state and never imply observed Codex Desktop lifecycle data. | Static localized presentation state |
| User gesture → Launch Services | Only fixed ChatGPT bundle and official usage URL handoffs leave the app. | Fixed bundle identifier or HTTPS URL |
| Privacy disclosure → user | Static copy distinguishes possible future data categories from currently enabled collection. | Localized disclosure text only |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation / Evidence | Status |
|-----------|----------|-----------|----------|-------------|-----------------------|--------|
| T-01-01 | Tampering | Upstream provenance | high | mitigate | `LICENSE.md` and `NOTICE` preserve Apache-2.0 attribution and pin upstream snapshot `4e7cf858`. | closed |
| T-01-02 | Spoofing | Product/bundle identity | high | mitigate | App/test targets and development bundle are renamed; inherited Claude/Sparkle identity scan passed. | closed |
| T-01-03 | Information disclosure | Inherited target membership | high | mitigate | Project inventory contains only the app and XCTest targets; credential, monitor, hook, and automation scans passed. | closed |
| T-01-04 | Elevation of privilege | Startup targets | high | mitigate | Empty Settings entry and target graph contain no helper, server, hook, updater, or automation target. | closed |
| T-01-SC | Tampering | Package-manager installs | low | accept | No npm, pip, cargo, or other package-manager install occurred; no external dependency was added. | closed |
| T-02-01 | Spoofing | Collapsed/expanded shell | high | mitigate | Fixed neutral local model and contract tests reject task/progress state; human UAT confirmed the collapsed shell. | closed |
| T-02-02 | Information disclosure | Inherited credential/private paths | high | mitigate | Identifier-aware production inventory and PhaseBoundaryTests reject inherited credential/private paths. | closed |
| T-02-03 | Tampering | Inherited hook/socket/update lifecycle | high | mitigate | Window-only startup plus source scans reject hook, socket, monitor, and updater symbols. | closed |
| T-02-04 | Elevation of privilege | Panel interaction | high | mitigate | Native bounded hit testing only; no global event reposting, accessibility automation, or synthetic input. | closed |
| T-02-SC | Tampering | Package-manager installs | low | accept | Existing native target and OS frameworks were sufficient; no package-manager install occurred. | closed |
| T-03-01 | Spoofing | Desktop card/header | high | mitigate | One fixed `Currently unobservable` card; tests and UAT reject inferred lifecycle, progress, history, approval, and control UI. | closed |
| T-03-02 | Information disclosure | Credential/private-data paths | high | mitigate | Production source contains no credential store, private reader, web view, or network client path. | closed |
| T-03-03 | Denial of service | App activation | medium | mitigate | In-flight coalescing, authoritative five-second timeout, explicit error, retry tests, and UAT passed. | closed |
| T-03-04 | Elevation of privilege | Desktop action | high | mitigate | `NSWorkspace` fixed-target activation only; no AX, CGEvent, injection, deep link, or task operation. | closed |
| T-03-05 | Tampering | App target selection | medium | mitigate | Ordered compile-time bundle set contains only verified `com.openai.codex`; equality/cardinality tests passed. | closed |
| T-03-SC | Tampering | Package-manager installs | low | accept | Native AppKit APIs and the existing target were sufficient; no package-manager install occurred. | closed |
| T-04-01 | Spoofing | Usage summary/detail | high | mitigate | Fixed `Usage unavailable` state; contract tests reject numeric, stale, chart, loading, or estimated quota UI. | closed |
| T-04-02 | Information disclosure | Credential/private-data reuse | high | mitigate | Default-browser handoff only; no web view, network, credential, parsing, cache, or retained account value. | closed |
| T-04-03 | Tampering | Inherited hook/socket/update side effects | high | mitigate | Menu import is row-only; production inventory remains clean of inherited lifecycle services. | closed |
| T-04-04 | Elevation of privilege | External navigation | high | mitigate | Launcher confines `NSWorkspace` to fixed app/URL targets; SwiftUI views contain no direct workspace calls. | closed |
| T-04-05 | Tampering | Official URL/app constants | medium | mitigate | Exact compile-time URL and bundle tests reject interpolation and mutable configuration. | closed |
| T-04-SC | Tampering | Package-manager installs | low | accept | Native frameworks and target-proven dependencies were sufficient; no package-manager install occurred. | closed |
| T-05-01 | Spoofing | Desktop/usage capability presentation | high | mitigate | Phase-wide contract suite and UAT enforce neutral Desktop and unavailable usage states. | closed |
| T-05-02 | Information disclosure | Credentials/private Desktop data | high | mitigate | Privacy assurance, PhaseBoundaryTests, and source scan reject Keychain, OAuth, cookies, private DBs, network, and UI-scraped task data. | closed |
| T-05-03 | Tampering | Inherited hook/socket/update services | high | mitigate | Production inventory rejects inherited lifecycle classes, feed URL, signing key, hooks, sockets, and monitors. | closed |
| T-05-04 | Elevation of privilege | UI automation/external task action | high | mitigate | Only fixed-target `NSWorkspace` calls are allowed; AX, CGEvent, process injection, and task-control APIs are rejected. | closed |
| T-05-05 | Tampering | Fixed URL/app boundaries | medium | mitigate | PhaseBoundaryTests prove exactly two fixed external targets with no interpolation or mutable configuration. | closed |
| T-05-SC | Tampering | Package-manager installs | low | accept | Phase 1 uses native APIs and retained target-proven dependencies only; no package-manager install occurred. | closed |

*Only open threats at or above `workflow.security_block_on: high` count toward `threats_open`.*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-01 | T-01-SC | No package-manager execution or dependency addition occurred. | Phase plan | 2026-08-18 |
| AR-02 | T-02-SC | Native target and OS frameworks fully cover the shell. | Phase plan | 2026-08-18 |
| AR-03 | T-03-SC | Native Launch Services covers the Desktop handoff. | Phase plan | 2026-08-18 |
| AR-04 | T-04-SC | Native browser handoff covers the usage entry. | Phase plan | 2026-08-18 |
| AR-05 | T-05-SC | No additional runtime or package manager is required for the privacy boundary. | Phase plan | 2026-08-18 |

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-08-18 | 28 | 28 | 0 | GSD secure-phase, ASVS L1 artifact verification |

---

## Sign-Off

- [x] All threats have a disposition
- [x] Accepted risks are documented
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-08-18
