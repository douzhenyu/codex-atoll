//
//  NotchWindowController.swift
//  CodexAtoll
//
//  Owns the native nonactivating panel and its closed/open placement.
//
//  Adapted from the Apache-2.0 Claude Atoll shell (see NOTICE): the panel and
//  status-stream placement are kept, while the boot animation and any
//  activity inference are removed. The window frame tracks the visible
//  content so the closed pill accepts native clicks without global monitors.
//

import AppKit
import SwiftUI

// MARK: - NotchPanel

/// Non-activating, borderless panel that hosts the notch shell.
final class NotchPanel: NSPanel {
    // MARK: Lifecycle

    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool,
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false,
        )

        isFloatingPanel = true
        becomesKeyOnlyIfNeeded = true

        // Transparent configuration
        isOpaque = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        backgroundColor = .clear
        hasShadow = false

        // Prevent the window from moving during space switches
        isMovable = false

        // Stays on all spaces, above the menu bar
        collectionBehavior = [
            .fullScreenAuxiliary,
            .stationary,
            .canJoinAllSpaces,
            .ignoresCycle,
        ]

        level = .mainMenu + 3
        allowsToolTipsWhenApplicationIsInactive = true

        // The window frame matches the visible content, so it accepts native
        // clicks directly; no global event monitor is used.
        ignoresMouseEvents = false

        isReleasedWhenClosed = true
        acceptsMouseMovedEvents = false
    }

    // MARK: Internal

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        false
    }
}

// MARK: - NotchWindowController

/// Owns the notch panel, its geometry, and the closed/open placement.
final class NotchWindowController: NSWindowController {
    // MARK: Lifecycle

    init(screen: NSScreen) {
        let screenFrame = screen.frame
        let notchSize = screen.notchSize
        let deviceNotchRect = CGRect(
            x: screenFrame.midX - notchSize.width / 2,
            y: screenFrame.maxY - notchSize.height,
            width: notchSize.width,
            height: notchSize.height,
        )
        let geometry = NotchGeometry(
            deviceNotchRect: deviceNotchRect,
            screenFrame: screenFrame,
        )
        self.viewModel = NotchViewModel(geometry: geometry)

        let panel = NotchPanel(
            contentRect: geometry.closedScreenRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false,
        )

        super.init(window: panel)

        let hostingController = NotchViewController(viewModel: self.viewModel)
        panel.contentViewController = hostingController
        panel.setFrame(geometry.closedScreenRect, display: true)

        let statusStream = self.viewModel.makeStatusStream()
        self.statusTask = Task { @MainActor [weak self] in
            for await status in statusStream {
                self?.apply(status: status)
            }
        }
    }

    deinit {
        statusTask?.cancel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    let viewModel: NotchViewModel

    // MARK: Private

    private var statusTask: Task<Void, Never>?

    /// Place the panel for the current state and accept native events.
    private func apply(status: NotchStatus) {
        guard let window else { return }
        let targetRect = status == .open
            ? self.viewModel.geometry.openedScreenRect
            : self.viewModel.geometry.closedScreenRect
        window.setFrame(targetRect, display: true, animate: true)

        switch status {
        case .open:
            // Accept events so the companion surface is interactive.
            window.ignoresMouseEvents = false
            NSApp.activate(ignoringOtherApps: false)
            window.makeKey()
        case .closed:
            // The closed pill accepts native clicks; the window frame is
            // exactly the pill, so nothing else needs passing through.
            window.ignoresMouseEvents = false
        }
    }
}
