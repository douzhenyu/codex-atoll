//
//  AppDelegate.swift
//  CodexAtoll
//
//  Window-only accessory lifecycle.
//
//  Adapted from the Apache-2.0 Claude Atoll shell (see NOTICE): only the
//  accessory activation policy, the notch controller, and screen-change
//  placement are kept. No hook installer, socket server, updater identity,
//  accessibility monitoring, or background integration starts here.
//

import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: Internal

    /// The single notch controller; one panel, no window-manager abstraction.
    private(set) var notchWindowController: NotchWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        self.installNotchWindow(on: Self.preferredScreen())

        // Observe screen changes only to maintain placement.
        self.screenChangeObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main,
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handleScreenChange()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let screenChangeObserver {
            NotificationCenter.default.removeObserver(screenChangeObserver)
        }
        self.screenChangeObserver = nil
        self.notchWindowController = nil
    }

    // MARK: Private

    private var screenChangeObserver: NSObjectProtocol?
    private var currentDisplayID: CGDirectDisplayID?

    private func handleScreenChange() {
        guard let screen = Self.preferredScreen() else { return }
        self.installNotchWindow(on: screen)
    }

    private func installNotchWindow(on screen: NSScreen?) {
        guard let screen else { return }

        let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
        if let displayID, displayID == self.currentDisplayID {
            return // Screen unchanged; keep current placement.
        }
        self.currentDisplayID = displayID

        self.notchWindowController?.window?.orderOut(nil)
        self.notchWindowController = NotchWindowController(screen: screen)
        self.notchWindowController?.showWindow(nil)
    }

    /// The built-in (notched) display when present, otherwise the primary.
    private static func preferredScreen() -> NSScreen? {
        NSScreen.builtin ?? NSScreen.screens.first
    }
}
