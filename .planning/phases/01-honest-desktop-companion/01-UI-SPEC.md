---
phase: 1
slug: honest-desktop-companion
status: draft
shadcn_initialized: false
preset: none
created: 2026-08-17
---

# Phase 1 — UI Design Contract

> Visual and interaction contract for the truthful Codex Desktop companion. This phase is a navigation and disclosure surface, not a Desktop task monitor or a local quota meter.

---

## Design System

| Property | Value |
|----------|-------|
| Tool | none — native SwiftUI/AppKit |
| Preset | not applicable |
| Component library | SwiftUI and AppKit system controls |
| Icon library | SF Symbols plus the bundled Codex product mark |
| Font | SF Pro / system font |
| Reused shell | Claude Atoll `NotchView`, `NotchViewModel`, `ModuleLayoutEngine`, `NotchModule`, `NotchMenuView` row patterns, and `NSWorkspace` opening pattern |

Do not port Claude Atoll's token rings, `TokenTrackingManager`, Keychain reads, OAuth settings, private usage API calls, or automatic hook-install controls. There is no shadcn registry or third-party UI block in this macOS phase.

---

## Spacing Scale

Declared values (all normal layout values are multiples of 4):

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Icon-to-label gap; compact card metadata gap |
| sm | 8px | Menu row inset; adjacent control gap |
| md | 16px | Card padding; default content gap |
| lg | 24px | Expanded-notch section separation |
| xl | 32px | Detail-view section separation |
| 2xl | 48px | Reserved only for a full-page privacy empty-state break |
| 3xl | 64px | Not used in the notch; retained as the shared scale ceiling |

Exceptions: use an 8px outer edge inset and 8px shape edge margin for the Phase 1 notch shell; do not carry forward the reference's noncompliant outer inset. Icon-only controls must have a 44px by 44px hit target even when their visible glyph is 16px.

---

## Typography

Use exactly these four sizes and two weights. Dynamic Type may scale them; do not introduce a third weight for status or errors.

| Role | Size | Weight | Line Height |
|------|------|--------|-------------|
| Compact status / metadata | 12px | 400 | 1.5 |
| Body / menu row | 14px | 400 | 1.5 |
| Card title / action label | 16px | 600 | 1.2 |
| Detail heading | 20px | 600 | 1.2 |

Use sentence case. Localize all user-facing strings; never use color, animation, or an abbreviated glyph as the only capability signal.

---

## Color

The inherited notch remains dark so it reads as part of macOS hardware, with text contrast meeting WCAG AA against its surface.

| Role | Value | Usage |
|------|-------|-------|
| Dominant (60%) | `#000000` | Notch background and expanded surface |
| Secondary (30%) | `#1C1C1E` | Desktop card, usage-unavailable detail card, privacy disclosure sections |
| Accent (10%) | `#10A37F` | `Open ChatGPT`, `Open official Codex usage`, active focus ring, and verified-data affordances only |
| Destructive | `#FF453A` | Reserved for a future local-data-clear confirmation; no destructive control ships in Phase 1 |
| Unavailable semantic | `#8E8E93` | Supplemental unavailable icon and divider only; accompanying text is required |

Accent reserved for: `Open ChatGPT`, `Open official Codex usage`, keyboard focus, and later officially verified usage data. Never use accent to imply an unobservable Desktop task is running, waiting, or controllable.

---

## Visual Hierarchy

The expanded default view has one focal point: the `Codex Desktop` companion card. Its fixed reading order is:

1. Source and capability badge: `Codex Desktop` and `Currently unobservable`.
2. Explanation: why current state, history, and approvals cannot be shown in Atoll.
3. Primary action: `Open ChatGPT`.

`Usage unavailable` is a secondary top-left header affordance, not a competing card or a source of task status. The top-right menu affordance is tertiary navigation.

---

## Component Inventory

| Element | Composition and placement | Required content | Phase 1 behavior |
|---------|---------------------------|------------------|------------------|
| Collapsed notch header | Reuse header/module layout. Codex mark is the leftmost module; neutral unavailable symbol is rightmost. | VoiceOver: `Codex Atoll. Codex Desktop is currently unobservable.` | No persistent `Open ChatGPT` button. Never show a spinner, progress ring, completion tick, approval badge, or inferred Desktop lifecycle state. Clicking anywhere on the notch opens the companion surface. |
| Expanded header | Preserve the inherited header row. Place the usage affordance at the top-left; menu affordance remains at the top-right. | `Usage unavailable` plus `Currently unobservable` icon for Phase 1. The icon-only menu control has accessibility label `Open Codex Atoll menu`. | The usage affordance is a button, not a percentage or reset timer. It opens the in-notch usage detail state. |
| Desktop companion card | First card in the expanded default view; 16px padding, source badge above title, capability badge beside title. | Source: `Codex Desktop`; title: `Codex Desktop`; capability: `Currently unobservable`; explanatory body; primary CTA. | One card has exactly one capability class. It contains no task list, history preview, approval button, prompt box, pause action, or state timeline. |
| Usage unavailable detail | In-notch detail view, replacing the default card list; top-left back control. | Heading, unavailable explanation, official-link CTA, privacy reassurance. | Displays no numeric quota, reset time, progress ring, chart, heatmap, skeleton, stale value, or retry spinner. |
| Privacy & Data page | In-notch menu destination using the existing scrollable menu/content pattern. | Plain-language data-boundary sections and future per-integration disclosure template. | Informational in Phase 1; no integration is enabled and no credential field is shown. |
| Menu rows | Reuse `MenuRow` visual and 8px vertical grouping. | `Open ChatGPT`, `Open official Codex usage`, `Privacy & Data`; retain non-Codex product settings only when still relevant after the fork. | URL/app actions use `NSWorkspace`; replace the reference's Claude token and Hooks rows rather than hiding unsupported behavior behind them. |

### Capability badges

Every capability badge contains its SF Symbol and literal text. Cards with mixed capabilities are split before rendering.

| Class | Icon | Label | Meaning | Phase 1 use |
|-------|------|-------|---------|-------------|
| Available | `checkmark.circle` | `Available` | Atoll has a supported, live route to perform the named work. | Reserved for later verified/owned session cards; not shown on the Desktop card. |
| Jump only | `arrow.up.right.square` | `Jump only` | The task can only be continued or inspected in its original app or official page. | Use for the official usage handoff card/detail. |
| Currently unobservable | `eye.slash` | `Currently unobservable` | Atoll has no trustworthy current task data or action channel. | Required on the Codex Desktop card. |

---

## Interaction Contract

### Notch opening and retraction

1. The notch is collapsed by default; there is no permanent quick-action button in its closed form.
2. A direct click opens the default companion view. It must not infer or display a Desktop task state while doing so.
3. Only a verified, blocking request from a future observable or Atoll-owned source may automatically open the notch. Phase 1 emits no such request, so it never auto-expands for Desktop activity.
4. For a valid future auto-expansion, retract after 5 seconds without interaction. Once interaction begins, retract 300ms after both pointer and keyboard focus leave. Cancel either retraction while the pointer or focus returns.
5. Close/open transitions use the inherited SwiftUI spring. With Reduce Motion enabled, use a 150ms opacity/size transition with no bounce or looping motion.

### Codex Desktop handoff

1. The expanded Desktop card always shows the source label `Codex Desktop` and the complete badge `Currently unobservable`.
2. Its body copy explains that Atoll cannot obtain current Codex runtime information and that task details, history, approvals, and actions remain in ChatGPT until an official integration exists.
3. `Open ChatGPT` activates the ChatGPT Desktop application with `NSWorkspace`. It does not claim that a specific task was focused.
4. If macOS cannot open/activate ChatGPT, keep the card open and replace the CTA feedback with the documented error copy. Do not silently fail, fall back to UI automation, or expose a disabled approval/history control.

### Usage handoff

1. The top-left expanded-header usage affordance reads `Usage unavailable`; it may include `arrow.up.right` but never a numerical placeholder, percentage, reset time, or loading indicator.
2. Clicking it navigates in place to the usage-unavailable detail. Back returns to the default expanded companion view without closing the notch.
3. `Open official Codex usage` opens the official usage/limits URL in the default browser. The app neither fetches the page nor reads account credentials.
4. A verified future provider may replace this unavailable presentation only when it supplies an official source, individual values, and an update timestamp. Its compact form must show `Remaining {percentage} · resets {time}`. Its detail view must show quota cards, a 30-day daily heatmap, the official source, and `Updated {time}`; a retained failed-refresh value must say `May be out of date`. Those verified-data states are deferred and are not Phase 1 acceptance criteria.

### Privacy disclosure

1. Do not show a generic blocking privacy modal at launch.
2. `Privacy & Data` is always reachable from the expanded-notch menu and gives the same information before any future integration is enabled.
3. Immediately before a future integration's enable action, show an integration-specific confirmation sheet. It identifies that integration and lists: prompt text; tool calls and results; session/status metadata; whether each category stays on device or leaves it; and its retention period.
4. The confirmation sheet starts with every integration disabled, provides `Enable {integration}` and `Not now`, and has no preselected consent. A later implementation must provide a reversible disable action and local-data clearing for Atoll-owned data.
5. The page and sheet must explicitly state that Codex Atoll does not request or read Codex OAuth tokens, session cookies, Keychain credentials, ChatGPT/Codex Desktop private databases, or UI-scraped task data.

---

## Copywriting Contract

| Element | Copy |
|---------|------|
| Primary CTA | `Open ChatGPT` |
| Desktop card source | `Codex Desktop` |
| Desktop capability | `Currently unobservable` |
| Desktop card body | `Codex Atoll cannot obtain current Codex runtime information. Review task details, history, approvals, and actions in ChatGPT until an official integration is available.` |
| Desktop app error | `ChatGPT could not be opened. Open it from Applications, then try again.` |
| Usage compact state | `Usage unavailable` |
| Usage detail heading | `Usage details unavailable here` |
| Usage detail body | `Codex Atoll does not read account credentials or estimate your quota. View current limits on the official Codex page.` |
| Usage CTA | `Open official Codex usage` |
| Usage handoff error | `The official Codex usage page could not be opened. Check your default browser, then try again.` |
| Privacy page heading | `Privacy & Data` |
| Privacy empty state | `No integrations are enabled` |
| Privacy empty-state body | `Codex Atoll is not monitoring Codex. Before an integration is enabled, you can review exactly what data it may process.` |
| Credential assurance | `Codex Atoll never asks for your Codex OAuth token, session cookie, or Keychain credential.` |
| Destructive confirmation | None in Phase 1. Future `Clear local data` confirmation: `Delete Codex Atoll's saved local activity? This cannot be undone and does not affect Codex or ChatGPT data.` |

---

## Accessibility and Content Resilience

- All controls have visible keyboard focus. `Open ChatGPT`, `Open official Codex usage`, the menu control labelled `Open Codex Atoll menu`, and back controls are reachable with VoiceOver and keyboard navigation.
- The Codex mark has an accessible label; a purely decorative unavailable glyph is hidden from VoiceOver when its adjacent badge label is announced.
- Capability is always conveyed by literal text plus icon. Color and motion are supplemental only.
- Card bodies wrap to two lines in the expanded notch, then truncate with an ellipsis. A VoiceOver hint exposes the full body. Do not let long localized strings cover the CTA; retain the CTA on its own final row.
- The expanded body scrolls vertically when content exceeds the inherited notch height. Headers, back action, and primary CTA remain reachable; do not shrink text below 12px.
- External launch actions have no data-loading state. Only the local action result may show transient `Opening ChatGPT…` text for up to 5 seconds, never a task-progress spinner.

---

## UI Considerations

Applicable state considerations resolved: 9 covered, 1 backstop, 0 unresolved.

| Category | Element(s) | Status | Resolution / Reason |
|----------|------------|--------|---------------------|
| empty | Privacy & Data integration state | ✅ covered | Shows `No integrations are enabled` and the documented next-step body. |
| loading | Desktop handoff and usage handoff controls | ✅ covered | No remote data loads in Phase 1; actions use bounded local launch feedback only and never display task/quota loading. |
| error | ChatGPT and official-usage launch actions | ✅ covered | Keep the current card/detail visible and render the documented actionable error copy. |
| populated | Expanded companion surface | ✅ covered | Always renders one source-labelled Codex Desktop card; it is not a discovered-task list. |
| overflow | Expanded view and menu | ✅ covered | Vertical scrolling preserves header, back action, and CTA reachability. |
| long-text | Desktop explanation, usage explanation, privacy content, CTA labels | ✅ covered | Body wraps to two lines then ellipsizes visually; full copy remains available to VoiceOver; CTA owns a separate final row. |
| error | Future integration disclosure sheet | 🧪 backstop | A future enable failure keeps the sheet open, reports the failed integration by name, and leaves consent off; verify when an enable action is introduced. |
| partial | Future verified usage data | ✅ covered | Phase 1 has no partial usage rendering. Future source data must either show all required source/freshness fields or fall back to the unavailable detail. |
| zero-one-many | Capability cards | ✅ covered | Phase 1 uses a fixed one-card Desktop companion; future mixed capabilities require independent cards rather than inline labels. |
| long-text | Collapsed notch status | ✅ covered | Closed state uses the fixed icon and neutral symbol only; full capability text is announced to VoiceOver and shown after expansion. |

---

## Registry Safety

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| Native SwiftUI/AppKit | Existing inherited components only | not applicable — no third-party registry |
| shadcn official | none | not applicable — no React/Vite/Next.js stack |

---

## Checker Sign-Off

- [ ] Dimension 1 Copywriting: PASS
- [ ] Dimension 2 Visuals: PASS
- [ ] Dimension 3 Color: PASS
- [ ] Dimension 4 Typography: PASS
- [ ] Dimension 5 Spacing: PASS
- [ ] Dimension 6 Registry Safety: PASS

**Approval:** pending
