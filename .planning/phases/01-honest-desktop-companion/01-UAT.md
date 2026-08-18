---
status: testing
phase: 01-honest-desktop-companion
source: [01-VERIFICATION.md]
started: 2026-08-18T14:55:00Z
updated: 2026-08-18T14:55:00Z
---

## Current Test

number: 1
name: Launch CodexAtoll.app and inspect the collapsed notch
expected: |
  Neutral collapsed shell with complete VoiceOver label 'Codex Atoll. Codex Desktop is currently unobservable.'; no inferred Desktop lifecycle, progress, or credential UI.
awaiting: user response

## Tests

### 1. Launch smoke + collapsed notch
expected: Launch CodexAtoll.app; collapsed notch shows Codex mark left, neutral eye.slash right, no shortcut/spinner, no automatic expansion; direct click opens the companion card; close returns to the neutral collapsed state. VoiceOver label complete.
result: [pending]

### 2. Open ChatGPT activation
expected: Click 'Open ChatGPT' with ChatGPT Desktop installed; native activation succeeds with no task-focus claim. Temporarily make bundle lookup fail; the card and exact retryable error stay visible.
result: [pending]

### 3. Open official Codex usage
expected: Click 'Open official Codex usage'; the default browser opens exactly https://chatgpt.com/codex/settings/usage; Atoll does not request credentials or scrape the page; page content stays external.
result: [pending]

### 4. VoiceOver / keyboard navigation
expected: Navigate every Phase 1 control with VoiceOver and keyboard: collapsed pill, Desktop card, usage affordance/detail, menu (Open ChatGPT / Open official Codex usage / Privacy & Data / Back / Quit), Privacy & Data disclosure rows. Literal capability labels announced; full truncated copy read; back/CTA reachable; 44px targets; Reduce Motion respected.
result: [pending]

### 5. Engineering decision (REVIEW WR-01): harden the Opening-state timeout
expected: Harden DesktopHandoffLauncher.runBounded()/runBoundedURLOpen() so the local Opening state cannot extend beyond five seconds when the underlying Launch Services call is slow or ignores Task cancellation. Timeout is authoritative for the state transition even when the losing child task does not observe cancellation.
result: [pending]

## Summary

total: 5
passed: 0
issues: 0
pending: 5
skipped: 0
blocked: 0

## Gaps
