//
//  NotchViewController.swift
//  CodexAtoll
//
//  Hosts the SwiftUI NotchView in AppKit with bounded pass-through hit testing.
//
//  Adapted from the Apache-2.0 Claude Atoll shell (see NOTICE): the hosting
//  view and hit-test boundary are kept, while all session/monitor inputs are
//  removed.
//

import AppKit
import SwiftUI

// MARK: - PassThroughHostingView

/// Custom NSHostingView that only accepts mouse events within the panel
/// bounds. Clicks outside the rect pass through to windows behind.
final class PassThroughHostingView<Content: View>: NSHostingView<Content> {
    var hitTestRect: () -> CGRect = { .zero }

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard self.hitTestRect().contains(point) else {
            return nil // Pass through to windows behind
        }
        return super.hitTest(point)
    }
}

// MARK: - NotchViewController

final class NotchViewController: NSViewController {
    // MARK: Lifecycle

    init(viewModel: NotchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func loadView() {
        let hosting = PassThroughHostingView(rootView: NotchView(viewModel: self.viewModel))
        // The window frame already matches the visible panel, so the hit-test
        // rect is the hosting view's own bounds. Bounded pass-through stays
        // in place so future panel shapes never capture outside clicks.
        hosting.hitTestRect = { [weak hosting] () -> CGRect in
            hosting?.bounds ?? .zero
        }
        self.hostingView = hosting
        view = hosting
    }

    // MARK: Private

    private let viewModel: NotchViewModel
    private var hostingView: PassThroughHostingView<NotchView>?
}
