//
//  NotchGeometry.swift
//  CodexAtoll
//
//  Pure geometry for the collapsed pill and expanded companion panel.
//
//  Adapted from the Apache-2.0 Claude Atoll shell (see NOTICE): only the
//  local placement math is kept — no global-event or activity inference.
//

import AppKit
import CoreGraphics
import Foundation

/// Pure geometry calculations for the notch shell.
struct NotchGeometry: Sendable {
    /// Reserved center area (physical notch region) in screen coordinates.
    let deviceNotchRect: CGRect

    /// Full screen frame in screen coordinates (origin bottom-left, Y up).
    let screenFrame: CGRect

    /// Horizontal edge inset of the closed pill.
    static let closedEdgeInset: CGFloat = 8

    /// Space between an icon strip and the reserved notch center.
    static let closedInterModuleSpacing: CGFloat = 8

    /// Width of each icon strip on the closed pill.
    static let closedIconStripWidth: CGFloat = 28

    /// Minimum closed pill height for displays without a physical notch.
    static let minimumClosedHeight: CGFloat = 36

    /// Closed pill content size.
    var closedContentSize: CGSize {
        let width = deviceNotchRect.width
            + 2 * Self.closedIconStripWidth
            + 2 * Self.closedInterModuleSpacing
            + 2 * Self.closedEdgeInset
        let height = max(deviceNotchRect.height, Self.minimumClosedHeight)
        return CGSize(width: width, height: height)
    }

    /// Closed pill frame in screen coordinates, centered and top-anchored.
    var closedScreenRect: CGRect {
        let size = closedContentSize
        return CGRect(
            x: screenFrame.midX - size.width / 2,
            y: screenFrame.maxY - size.height,
            width: size.width,
            height: size.height,
        )
    }

    /// Expanded companion content size.
    var openedContentSize: CGSize {
        CGSize(
            width: min(screenFrame.width * 0.5, 600),
            height: 340,
        )
    }

    /// Expanded panel frame in screen coordinates, centered and top-anchored.
    var openedScreenRect: CGRect {
        let size = openedContentSize
        return CGRect(
            x: screenFrame.midX - size.width / 2,
            y: screenFrame.maxY - size.height,
            width: size.width,
            height: size.height,
        )
    }
}

// MARK: - NSScreen notch helpers

extension NSScreen {
    /// Reserved notch exclusion size on this screen.
    /// Width is conservative so closed-pill content stays outside the physical notch.
    var notchSize: CGSize {
        guard safeAreaInsets.top > 0 else {
            // Fallback for non-notch displays (matches a typical MacBook notch).
            return CGSize(width: 224, height: 38)
        }
        return CGSize(
            width: reservedNotchExclusionWidth,
            height: safeAreaInsets.top,
        )
    }

    /// Conservatively reserved center width where closed content must not render.
    var reservedNotchExclusionWidth: CGFloat {
        let baseWidth = notchExclusionBaseWidth
        return baseWidth + Self.notchSafetyPadding * 2
    }

    /// Base width before safety padding, derived from macOS top auxiliary areas.
    var notchExclusionBaseWidth: CGFloat {
        let leftPadding = auxiliaryTopLeftArea?.width ?? 0
        let rightPadding = auxiliaryTopRightArea?.width ?? 0

        guard leftPadding > 0, rightPadding > 0 else {
            // Fallback if auxiliary areas are unavailable on a notched display.
            return 224
        }

        return max(0, frame.width - leftPadding - rightPadding)
    }

    /// Whether this is the built-in display.
    var isBuiltinDisplay: Bool {
        guard let screenNumber = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
            return false
        }
        return CGDisplayIsBuiltin(screenNumber) != 0
    }

    /// The built-in display (with a notch on newer MacBooks).
    static var builtin: NSScreen? {
        screens.first { $0.isBuiltinDisplay }
    }

    /// Whether this screen has a physical notch (camera housing).
    var hasPhysicalNotch: Bool {
        safeAreaInsets.top > 0
    }

    private static let notchSafetyPadding: CGFloat = 12
}
