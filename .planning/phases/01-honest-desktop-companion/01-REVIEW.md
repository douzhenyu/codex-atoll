---
phase: 01-honest-desktop-companion
reviewed: 2026-08-18T00:00:00Z
depth: standard
files_reviewed: 27
files_reviewed_list:
  - .gitignore
  - CodexAtoll.xcodeproj/project.pbxproj
  - CodexAtoll.xcodeproj/xcshareddata/xcschemes/CodexAtoll.xcscheme
  - CodexAtoll/App/AppDelegate.swift
  - CodexAtoll/App/CodexAtollApp.swift
  - CodexAtoll/Core/CapabilityClass.swift
  - CodexAtoll/Core/DesktopHandoffLauncher.swift
  - CodexAtoll/Core/NotchGeometry.swift
  - CodexAtoll/Core/NotchViewModel.swift
  - CodexAtoll/Resources/Assets.xcassets/CodexMark.imageset/Contents.json
  - CodexAtoll/Resources/Assets.xcassets/CodexMark.imageset/codex-mark.svg
  - CodexAtoll/Resources/Assets.xcassets/Contents.json
  - CodexAtoll/Resources/Localizable.xcstrings
  - CodexAtoll/UI/Components/CapabilityBadge.swift
  - CodexAtoll/UI/Components/MenuRow.swift
  - CodexAtoll/UI/Views/DesktopCompanionView.swift
  - CodexAtoll/UI/Views/NotchMenuView.swift
  - CodexAtoll/UI/Views/NotchView.swift
  - CodexAtoll/UI/Views/PrivacyDataView.swift
  - CodexAtoll/UI/Views/UsageUnavailableView.swift
  - CodexAtoll/UI/Window/NotchViewController.swift
  - CodexAtoll/UI/Window/NotchWindowController.swift
  - CodexAtollTests/CapabilityContractTests.swift
  - CodexAtollTests/DesktopHandoffLauncherTests.swift
  - CodexAtollTests/PhaseBoundaryTests.swift
  - LICENSE.md
  - NOTICE
findings:
  critical: 0
  warning: 3
  info: 4
  total: 7
status: issues_found
---

# Phase 01: Code Review Report

**Reviewed:** 2026-08-18T00:00:00Z
**Depth:** standard
**Files Reviewed:** 27
**Status:** issues_found

## Summary

Reviewed the complete Phase 01 "Honest Desktop Companion" surface: the AppKit notch shell (AppDelegate, NotchWindowController, NotchViewController, NotchGeometry, NotchViewModel), the SwiftUI companion/menu/usage/privacy views, the bounded `DesktopHandoffLauncher` boundary, resources (xcstrings, asset catalog, project file), and the three contract/boundary test files.

**High-level assessment:** The phase contracts are largely honored. The external-target inventory is exactly two fixed compile-time constants (bundle `com.openai.codex`, HTTPS usage URL), no inherited hook/updater/credential/UI-automation/network/persistence code survives (verified by direct read and confirmed by the identifier-aware source scans), localization catalog covers every `String(localized:)` key, and the boundary tests meaningfully enforce the forbiddance inventory. Accessibility basics (44px targets, literal capability labels, full VoiceOver copy) are in place and contract-tested.

The real defects found are in robustness rather than the boundary contract: the launcher's task-group timeout does not actually bound the `.opening` state when the underlying Launch Services call is slow or non-cancellable; the status stream's termination handler clobbers a recreated continuation; and the notch window is not repositioned on same-display resolution/arrangement changes. None is a data-loss or injection risk, so no BLOCKER is raised; WR-01 in particular undermines a headline phase promise ("the local Opening… state ends within five seconds") and should be addressed before ship.

## Warnings

### WR-01: The 5-second timeout does not actually bound the `.opening` state

**File:** `CodexAtoll/Core/DesktopHandoffLauncher.swift:149-171` (also 197-217)
**Issue:** `runBounded()` races the open call against a `Task.sleep` timeout inside `withTaskGroup`. When the timeout child wins, `group.cancelAll()` is called and the body returns — but `withTaskGroup` **implicitly awaits all remaining child tasks** before returning. The function therefore does not return when the timeout fires; it returns only when the open child *also* finishes. If `performOpen()`'s underlying `NSWorkspace.openApplication` (or `open`) is slow or does not observe Task cancellation, `finish(_:)` is never called, `state` stays `.opening` indefinitely, and the coalescing guard in `openChatGPT()` (line 128) blocks every subsequent tap. The tests pass only because the fakes' `Task.sleep` is cancellation-cooperative and exits within milliseconds of `cancelAll()`. This contradicts the documented and UI-SPEC-mandated promise (UI-SPEC line 202; launcher doc lines 100-102, 134-136) that the `Opening…` state ends within five seconds.
**Fix:** Make the timeout authoritative by not awaiting the losing child for the state transition. For example, fire the open in a task owned by the launcher, race a cancellation-safe timeout, and settle `state` from the first result only — leaving the cancelled loser detached (its late result is discarded):

```swift
private func runBounded() async -> HandoffOutcome {
    let openTask = Task { await self.performOpen() }
    let result = await withTaskGroup(of: HandoffOutcome.self) { group in
        group.addTask { await openTask.value }
        group.addTask {
            try? await Task.sleep(for: self.timeout)
            return HandoffOutcome.failure(.timedOut)
        }
        guard let first = await group.next() else { return .failure(.timedOut) }
        group.cancelAll()
        openTask.cancel()
        return first
    }
    // NOTE: even this still waits on openTask at group exit. The robust
    // fix is to settle state from the *first* result outside the group,
    // e.g. via a continuation resumed by whichever task finishes first,
    // so a hung OS call can never extend `.opening`.
    return result
}
```

At minimum, wrap the workspace calls with `withTaskCancellationHandler`-style release-on-cancel so a cancelled request cannot keep the surface stuck, and add a test whose fake ignores cancellation to prove the bound.

### WR-02: Re-calling `makeStatusStream()` clobbers the newly created continuation

**File:** `CodexAtoll/Core/NotchViewModel.swift:68-83`
**Issue:** The `onTermination` handler unconditionally schedules `self?.statusContinuation = nil` on a later MainActor turn. If `makeStatusStream()` is called twice (the API explicitly documents this as supported: "calling again finishes the previous stream and yields the current status immediately"), the deferred nil-out runs *after* the second continuation has been assigned, setting `statusContinuation = nil` and permanently detaching the second stream. The window controller's `for await` loop would then never receive further `status` updates. Today there is only one call site (per view model), so the bug is latent, but the public contract invites the second call.
**Fix:** Only nil the continuation if it is still the one that terminated, and do it synchronously on the main actor rather than through a deferred task:

```swift
func makeStatusStream() -> AsyncStream<NotchStatus> {
    self.statusContinuation?.finish()
    let (stream, continuation) = AsyncStream.makeStream(
        of: NotchStatus.self,
        bufferingPolicy: .bufferingNewest(1),
    )
    self.statusContinuation = continuation
    continuation.onTermination = { @MainActor [weak self] _ in
        guard let self else { return }
        // Only clear if this continuation is still the current one.
        Task { @MainActor in
            if self.statusContinuation === continuation {
                self.statusContinuation = nil
            }
        }
    }
    continuation.yield(self.status)
    return stream
}
```

### WR-03: Same-display resolution/arrangement changes leave the notch misplaced

**File:** `CodexAtoll/App/AppDelegate.swift:55-67`
**Issue:** `installNotchWindow(on:)` early-returns when `displayID == self.currentDisplayID` ("Screen unchanged; keep current placement"). `NSApplication.didChangeScreenParametersNotification` also fires on resolution changes, display arrangement, and scale-factor changes where the display ID is unchanged but the screen frame (`midX`, `maxY`, width) changes. In those cases the panel keeps its old frame, so the pill can end up off-center or off-screen until the display actually changes. The comment frames the guard as a dedup optimization, but it also suppresses legitimate re-placement.
**Fix:** Compare the current *frame* (or a geometry hash) rather than only the display ID, so resolution/arrangement changes recompute placement while true no-op notifications still return early:

```swift
private func installNotchWindow(on screen: NSScreen?) {
    guard let screen else { return }
    let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
    if let displayID, displayID == self.currentDisplayID, screen.frame == self.currentScreenFrame {
        return
    }
    self.currentDisplayID = displayID
    self.currentScreenFrame = screen.frame
    ...
}
```

## Info

### IN-01: 44px header controls overflow the ~36–38px header row

**File:** `CodexAtoll/UI/Views/NotchView.swift:259-292` (header row height at 246 via `closedHeight`, `NotchView.swift:175-177`)
**Issue:** `closedHeight` is `max(deviceNotchRect.height, NotchGeometry.minimumClosedHeight)` — 36px on a notched display, 38px otherwise. The expanded header's usage affordance (`.frame(height: 44)`, line 272) and menu button (`.frame(width: 44, height: 44)`, line 287) are taller than the 38px row, so they overflow ~3–4px past the row on both sides. The 44px hit target is spec-mandated, so the overflow is partly intentional, but the visible 12–16px glyphs are vertically off-center within the row and the transparent overflow band overlaps the route content below.
**Fix:** Keep the 44px hit target but constrain the visual content to the row (e.g., center the glyph/label and use `.contentShape(Rectangle().inset(by:))` on the 44px frame), or increase the header row height to accommodate 44px controls consistently.

### IN-02: Source-scan test helpers silently skip when the repo layout/path changes

**File:** `CodexAtollTests/CapabilityContractTests.swift:508-529`, `CodexAtollTests/PhaseBoundaryTests.swift:180-201`
**Issue:** Both helpers resolve the production source directory from `#filePath` (test file path minus `CodexAtollTests`) and throw `XCTSkip` when the enumerator returns nil or a named file is missing. If the repo is checked out at a different absolute path (CI build machine, sandbox), moved, or restructured, the entire forbiddance-inventory coverage silently skips instead of failing — losing the very guarantees these tests exist to enforce.
**Fix:** Prefer a bundle-relative resource reference or fall back to failing loudly (`XCTFail` with a message) rather than skipping, so coverage loss is visible.

### IN-03: Accessory activation policy applied at runtime without `LSUIElement`

**File:** `CodexAtoll/App/AppDelegate.swift:22`; `CodexAtoll.xcodeproj/project.pbxproj` (generated Info.plist, no `INFOPLIST_KEY_LSUIElement`)
**Issue:** The app starts as a regular app (Dock icon visible) and calls `setActivationPolicy(.accessory)` in `applicationDidFinishLaunching`, which can produce a brief Dock-icon flash and depends on the policy switch succeeding after launch. Declaring the accessory policy in Info.plist avoids the flash and the timing dependence.
**Fix:** Add `INFOPLIST_KEY_LSUIElement = YES` (or a manual Info.plist key) to the app target build settings, keeping the runtime `setActivationPolicy(.accessory)` call as defense in depth.

### IN-04: `MainActor.assumeIsolated` couples correctness to main-queue delivery

**File:** `CodexAtoll/App/AppDelegate.swift:26-34`
**Issue:** The screen-change notification closure relies on `queue: .main` and `MainActor.assumeIsolated`. This is safe today because the main queue is the main actor's executor, but any future change to a background queue would make `assumeIsolated` trap. A `@MainActor`-annotated helper called from the closure (or an explicit main-queue hop) would make the intent static and robust.
**Fix:** Extract the body into a `@MainActor func handleScreenChange()` and call it from the closure via `MainActor.assumeIsolated { handleScreenChange() }` (as is effectively done), or dispatch the observer body onto the main actor explicitly so the isolation is compiler-checked rather than asserted.

---

_Reviewed: 2026-08-18T00:00:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
