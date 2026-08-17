# Phase 1: Honest Desktop Companion - Pattern Map

**Mapped:** 2026-08-17  
**Files analyzed:** 17 planned files  
**Analogs found:** 15 / 17

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `CodexAtoll/App/CodexAtollApp.swift` | app entry | event-driven | `ClaudeAtoll/App/ClaudeAtollApp.swift` | exact |
| `CodexAtoll/App/AppDelegate.swift` | lifecycle controller | event-driven | `ClaudeAtoll/App/AppDelegate.swift` | role-match; remove side effects |
| `CodexAtoll/App/WindowManager.swift` | window controller | event-driven | `ClaudeAtoll/App/WindowManager.swift` | exact |
| `CodexAtoll/Core/NotchViewModel.swift` | store/router | event-driven | `ClaudeAtoll/Core/NotchViewModel.swift` | role-match; simplify routes |
| `CodexAtoll/Core/DesktopHandoffLauncher.swift` | service | request-response | `NotchMenuView.swift` URL action | partial; research-defined error mapping |
| `CodexAtoll/Core/NotchGeometry.swift` | utility/model | transform | `ClaudeAtoll/Core/NotchGeometry.swift` | exact |
| `CodexAtoll/UI/Window/NotchWindow.swift` | window | event-driven | `ClaudeAtoll/UI/Window/NotchWindow.swift` | exact |
| `CodexAtoll/UI/Window/NotchWindowController.swift` | controller | event-driven | `ClaudeAtoll/UI/Window/NotchWindowController.swift` | role-match; no boot/lifecycle inference |
| `CodexAtoll/UI/Window/NotchViewController.swift` | controller | request-response | `ClaudeAtoll/UI/Window/NotchViewController.swift` | role-match; remove monitor dependency |
| `CodexAtoll/UI/Views/NotchView.swift` | component | event-driven | `ClaudeAtoll/UI/Views/NotchView.swift` | role-match; fixed Desktop state |
| `CodexAtoll/UI/Views/DesktopCompanionView.swift` | component | request-response | `ClaudeAtoll/UI/Views/ClaudeInstancesView.swift` | partial; new fixed card |
| `CodexAtoll/UI/Views/UsageUnavailableView.swift` | component | request-response | `ClaudeAtoll/UI/Views/NotchMenuView.swift` | role-match |
| `CodexAtoll/UI/Views/PrivacyDataView.swift` | component | static/transform | `ClaudeAtoll/UI/Views/NotchMenuView.swift` | partial; new static disclosure |
| `CodexAtoll/UI/Views/NotchMenuView.swift` | component | request-response | `ClaudeAtoll/UI/Views/NotchMenuView.swift` | role-match; retain rows only |
| `CodexAtoll/UI/Components/MenuRow.swift` | component | request-response | `NotchMenuView.swift:558-601` | exact extraction |
| `CodexAtollTests/CapabilityContractTests.swift` | test | transform | no close Phase-1 analog | none |
| `CodexAtollTests/DesktopHandoffLauncherTests.swift` | test | request-response | no close Phase-1 analog | none |

## Pattern Assignments

### `CodexAtoll/App/CodexAtollApp.swift` (app entry, event-driven)

**Analog:** `/Users/dou/claude-atoll/ClaudeAtoll/App/ClaudeAtollApp.swift`

**AppKit bridge** (lines 8-20):

```swift
import SwiftUI

@main
struct ClaudeAtollApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}
```

Rename the type/product only. This is the full entry-point pattern; do not add a normal SwiftUI app window because the notch is owned by the custom AppKit panel.

---

### `CodexAtoll/App/AppDelegate.swift` and `WindowManager.swift` (lifecycle controller, event-driven)

**Analogs:** `/Users/dou/claude-atoll/ClaudeAtoll/App/AppDelegate.swift`; `/Users/dou/claude-atoll/ClaudeAtoll/App/WindowManager.swift`

**Safe lifecycle core** (`AppDelegate.swift:46-65`):

```swift
func applicationDidFinishLaunching(_ notification: Notification) {
    NSApplication.shared.setActivationPolicy(.accessory)
    self.windowManager = WindowManager()
    _ = self.windowManager?.setupNotchWindow()
    self.screenObserver = ScreenObserver { [weak self] in
        self?.handleScreenChange()
    }
}
```

**Window recreation** (`WindowManager.swift:56-67`):

```swift
if let existingController = windowController {
    existingController.window?.orderOut(nil)
    existingController.window?.close()
    self.windowController = nil
}

self.windowController = NotchWindowController(screen: screen, animateOnLaunch: shouldAnimate)
self.windowController?.showWindow(nil)
```

**Do not copy** (`AppDelegate.swift:11-27`, `52-54`, `67-78`, `81-95`): Sparkle construction/checks, `HookInstaller.installIfNeeded()`, socket cleanup, interrupt watchers, or accessibility permission monitoring. Phase 1 starts only the window shell and screen observer; it must not install any integration before a future disclosure is accepted.

---

### `CodexAtoll/Core/NotchViewModel.swift` (store/router, event-driven)

**Analog:** `/Users/dou/claude-atoll/ClaudeAtoll/Core/NotchViewModel.swift`

**Observable state + AppKit status stream** (lines 52-68, 91-95, 143-150):

```swift
@Observable
final class NotchViewModel {
    var status: NotchStatus = .closed {
        didSet { self.statusContinuation?.yield(self.status) }
    }

    func makeStatusStream() -> AsyncStream<NotchStatus> {
        self.statusContinuation?.finish()
        let (stream, continuation) = AsyncStream.makeStream(
            of: NotchStatus.self, bufferingPolicy: .bufferingNewest(1)
        )
        self.statusContinuation = continuation
        continuation.yield(self.status)
        return stream
    }
}
```

**Open/close shape** (`NotchViewModel.swift:154-187`): use the same `notchOpen`/`notchClose` ownership and `openedSize` calculation, but replace `instances/menu/chat` with exactly local routes `companion`, `usageUnavailable`, and `privacy`/`menu`.

**Do not copy** (`NotchViewModel.swift:296-400`): global mouse monitoring, 50ms event throttling, posted CGEvents, hover expansion, or chat-stickiness. Phase 1 opens by native panel interaction and has no verified Desktop event that can auto-expand.

---

### `CodexAtoll/Core/DesktopHandoffLauncher.swift` (service, request-response)

**Closest analog:** `/Users/dou/claude-atoll/ClaudeAtoll/UI/Views/NotchMenuView.swift:156-167`

**Existing simple URL handoff**:

```swift
if let url = URL(string: "https://github.com/engels74/claude-atoll") {
    NSWorkspace.shared.open(url)
}
```

Use this only as the visual/menu call-site convention. Implement one concrete launcher with the research-defined `idle/opening/error` result for the two Phase-1 handoffs: registered ChatGPT activation and the official usage URL. Preserve the originating view on error, bound `Opening…` feedback to 5 seconds, and never claim task focus or automate the Desktop UI.

**Testing seam:** inject only a thin launcher/workspace boundary for this file's XCTest cases; do not introduce a provider framework.

---

### `CodexAtoll/UI/Window/{NotchWindow,NotchWindowController,NotchViewController}.swift` (window/controller, event-driven)

**Analogs:** `/Users/dou/claude-atoll/ClaudeAtoll/UI/Window/NotchWindowController.swift`; `/Users/dou/claude-atoll/ClaudeAtoll/UI/Window/NotchViewController.swift`

**Non-activating custom panel** (`NotchWindowController.swift:47-59`):

```swift
let notchWindow = NotchPanel(
    contentRect: windowFrame,
    styleMask: [.borderless, .nonactivatingPanel],
    backing: .buffered,
    defer: false
)
let hostingController = NotchViewController(viewModel: viewModel)
notchWindow.contentViewController = hostingController
```

**Mouse pass-through boundary** (`NotchViewController.swift:15-24`):

```swift
override func hitTest(_ point: NSPoint) -> NSView? {
    guard self.hitTestRect().contains(point) else { return nil }
    return super.hitTest(point)
}
```

**State-driven event acceptance** (`NotchWindowController.swift:66-87`): retain the status-stream mapping that lets the opened panel accept events and the closed panel pass them through. Remove the notification-specific focus behavior and boot-animation trigger unless it can be shown without implying Desktop activity.

**Do not copy** (`NotchViewController.swift:90-120`): `ClaudeSessionMonitor`, `NotchActivityCoordinator`, or `AccessibilityPermissionManager` inputs when calculating the closed width. Compute the Phase-1 fixed Codex left mark and neutral right symbol locally.

---

### `CodexAtoll/UI/Views/NotchView.swift` (component, event-driven)

**Analog:** `/Users/dou/claude-atoll/ClaudeAtoll/UI/Views/NotchView.swift`

**Shell composition** (lines 35-56):

```swift
ZStack(alignment: .top) {
    VStack(spacing: 0) { self.notchPanel }
}
.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
.preferredColorScheme(.dark)
.onChange(of: self.viewModel.status) { oldStatus, newStatus in
    self.handleStatusChange(from: oldStatus, to: newStatus)
}
```

**Local route switch** (`NotchView.swift:446-466`):

```swift
switch self.viewModel.contentType {
case .instances: ClaudeInstancesView(...)
case .menu: NotchMenuView(viewModel: self.viewModel)
case let .chat(session): ChatView(...)
}
```

Replace that switch with the Phase-1 local views only: desktop companion, usage unavailable, and privacy/menu. The collapsed header is always a Codex mark on the left and static neutral unavailable glyph on the right; click opens the companion.

**Do not copy** (`NotchView.swift:45-102`, `107-164`, `469-510`): `ClaudeSessionMonitor.startMonitoring`, session observation, `TokenTrackingManager`, activity coordinator, processing/approval branches, token rings, `ProgressView`, or visibility derived from sessions. Desktop is unobservable and must remain static.

---

### `CodexAtoll/UI/Views/{DesktopCompanionView,UsageUnavailableView,PrivacyDataView}.swift` (components, request-response/static)

**Closest analogs:** `/Users/dou/claude-atoll/ClaudeAtoll/UI/Views/ClaudeInstancesView.swift`; `/Users/dou/claude-atoll/ClaudeAtoll/UI/Views/NotchMenuView.swift`

There is no safe source-data analog for these views; build fixed local SwiftUI cards under the same dark, scrollable view conventions. They must contain the approved UI-SPEC copy, native `Button` controls, and no session monitor, data fetch, disabled approval, token ring, or skeleton state.

**Scrollable menu/content container** (`NotchMenuView.swift:29-39`):

```swift
ScrollView(.vertical, showsIndicators: true) {
    VStack(spacing: 4) {
        // local rows or cards
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 8)
}
```

Required fixed facts:

- `DesktopCompanionView`: source `Codex Desktop`, `eye.slash` + `Currently unobservable`, exact explanation, and `Open ChatGPT`.
- `UsageUnavailableView`: no quota figures/heatmap/spinner; `Open official Codex usage` only.
- `PrivacyDataView`: local disclosure of prompt text, tool calls/results, session/status metadata, processing location, retention, revocation/Atoll-owned-data clearing, and the explicit credential/private-data exclusions. It is informational; no integration toggle or consent submission exists in Phase 1.

---

### `CodexAtoll/UI/Views/NotchMenuView.swift` and `UI/Components/MenuRow.swift` (component, request-response)

**Analog:** `/Users/dou/claude-atoll/ClaudeAtoll/UI/Views/NotchMenuView.swift`

**Reusable action row** (`NotchMenuView.swift:558-600`):

```swift
Button(action: self.action) {
    HStack(spacing: 10) {
        Image(systemName: self.icon).frame(width: 16)
        Text(self.label)
        Spacer()
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
}
.buttonStyle(.plain)
.onHover { self.isHovered = $0 }
```

Retain a minimal menu with `Open ChatGPT`, `Open official Codex usage`, `Privacy & Data`, back, and quit (plus only product-neutral settings proven useful). Route launch actions through `DesktopHandoffLauncher`, not direct bare calls, so failures are rendered on their owning surfaces.

**Do not copy** (`NotchMenuView.swift:39-170`, `209-226`): Hook toggle/install/uninstall, accessibility row, token tracking row, OAuth/session-key UI, Sparkle update UI, Claude GitHub link, or `@AppStorage` settings tied to those features.

---

### `CodexAtollTests/CapabilityContractTests.swift` and `DesktopHandoffLauncherTests.swift` (tests)

**No close analog found.** The reference test suite covers live Claude behavior, which is out of scope. Use XCTest with small pure/unit seams:

- Assert the Desktop card contract exposes `Codex Desktop` and `Currently unobservable`, with no live-state/action routes.
- Assert usage is unavailable without an official provider and the official URL is the only external route.
- Assert privacy copy covers every required category/exclusion.
- Assert launcher maps absent application, open error, activation failure, and success into `idle/opening/error`/success outcomes without UI automation.
- Add a source-boundary test or script scan forbidding `Keychain`, `OAuth`, `TokenTracking`, `ClaudeAPIService`, `HookSocketServer`, `ClaudeSessionMonitor`, and old Claude identity in production target sources.

## Shared Patterns

### Native SwiftUI/AppKit shell

**Sources:** `ClaudeAtollApp.swift:8-20`, `NotchWindowController.swift:47-87`, `NotchViewController.swift:15-85`  
**Apply to:** app entry, window manager/controller, notch root.

Use the existing custom non-activating panel plus bounded pass-through hosting; this is native macOS behavior, not an accessibility/UI-automation mechanism.

### Local navigation and truthful state

**Sources:** `NotchViewModel.swift:32-45`, `154-187`; `NotchView.swift:446-466`  
**Apply to:** notch root, menu, usage and privacy surfaces.

Use a tiny explicit enum for local destinations. Phase 1 has no remote/data-driven state and must compile with fixed Desktop capability strings.

### External handoff and errors

**Source:** `NotchMenuView.swift:156-167` (basic `NSWorkspace` URL pattern); Phase research Pattern 2  
**Apply to:** `DesktopHandoffLauncher`, Desktop card, usage detail, menu.

Use one result-bearing native launcher. Success only confirms that macOS accepted a launch/open request; error remains visible on the initiating card/detail. No deep-link guessing, page scraping, process injection, or synthetic Desktop controls.

### Accessibility and visual status

**Source:** `01-UI-SPEC.md`, sections "Capability badges" and "Accessibility and Content Resilience"  
**Apply to:** all controls/cards.

Use SF Symbol plus literal text for capability. The right-side collapsed Desktop glyph is neutral/static. The deferred running animation may be implemented only after an official or Atoll-owned source delivers a current lifecycle event, respecting Reduce Motion.

## Explicit Exclusions From the Claude Atoll Reference

| Reference area | Why it must not be copied in Phase 1 |
|---|---|
| `Services/Hooks/HookInstaller*.swift` and `AppDelegate.swift:52-54` | Automatic integration enablement violates the pre-enable disclosure rule. |
| `Services/Hooks/HookSocketServer.swift` | Uses a predictable `/tmp/claude-atoll.sock`, broad socket permissions, and Claude protocol; future Codex IPC has separate authenticated design work. |
| `Core/TokenTrackingManager*.swift`, `Services/TokenTracking/*`, token modules/rings | Read/store OAuth/Keychain/private usage data and would fabricate a forbidden Phase-1 usage source. |
| `Services/Session/ClaudeSessionMonitor.swift`, session/chat/approval/tmux UI | Represents Claude runtime state; Phase 1 must not synthesize equivalent Codex Desktop state or controls. |
| `Info.plist`, Sparkle updater/user driver, Claude app icon/bundle/log identity | Old product identity/feed/key must never ship under Codex Atoll. Keep updates disabled until Phase 6 assigns a new signed identity. |
| Global event monitor / reposted click flow in `NotchViewModel.swift:296-400` | Phase 1 has no verified auto-expansion event and must not request/accessibility-drive Desktop control. |

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| `CodexAtoll/Core/DesktopHandoffLauncher.swift` | service | request-response | Reference performs fire-and-forget URL opens; it has no result-bearing ChatGPT activation layer. |
| `CodexAtollTests/CapabilityContractTests.swift` | test | transform | Reference tests live Claude session behavior, not an intentionally static capability-honest view. |
| `CodexAtollTests/DesktopHandoffLauncherTests.swift` | test | request-response | No injection-based native handoff tests exist in the reference. |

## Metadata

**Analog search scope:** `/Users/dou/claude-atoll/ClaudeAtoll/{App,Core,UI,Services}`  
**Files scanned:** 20 focused Swift files  
**Pattern extraction date:** 2026-08-17
