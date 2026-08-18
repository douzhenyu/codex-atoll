//
//  NotchViewModel.swift
//  CodexAtoll
//
//  Local shell state for the collapsed pill and the single companion route.
//
//  Adapted from the Apache-2.0 Claude Atoll shell (see NOTICE). This model
//  owns ONLY panel and local-route state. It carries no Desktop lifecycle,
//  history, approval, prompt, pause, task list, percentage, progress
//  animation, integration, or credential state.
//

import AppKit
import Observation
import SwiftUI

// MARK: - NotchStatus

enum NotchStatus: Equatable, Sendable {
    case closed
    case open
}

// MARK: - NotchDestination

/// The single local destination. No task, account, credential, integration,
/// or provider data is carried by the route value.
enum NotchDestination: Equatable, Sendable {
    case companion
}

// MARK: - NotchViewModel

/// Local open/close state and the newest-value status stream AppKit consumes
/// to place the panel. Direct-click open/close actions only — Phase 1 emits
/// no verified blocking request, so no automatic expansion exists here.
@Observable
final class NotchViewModel {
    // MARK: Lifecycle

    init(geometry: NotchGeometry) {
        self.geometry = geometry
    }

    // MARK: Internal

    /// The collapsed/open panel state. `didSet` feeds the AppKit status stream.
    var status: NotchStatus = .closed {
        didSet {
            self.statusContinuation?.yield(self.status)
        }
    }

    /// The single local route. Fixed to `.companion` in Phase 1.
    let destination: NotchDestination = .companion

    /// Pure geometry used by the shell and window placement.
    let geometry: NotchGeometry

    /// Create a stream of status changes for non-SwiftUI contexts (window
    /// controller placement). Single-consumer: calling again finishes the
    /// previous stream and yields the current status immediately.
    func makeStatusStream() -> AsyncStream<NotchStatus> {
        self.statusContinuation?.finish()

        let (stream, continuation) = AsyncStream.makeStream(
            of: NotchStatus.self,
            bufferingPolicy: .bufferingNewest(1),
        )
        self.statusContinuation = continuation
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.statusContinuation = nil
            }
        }
        continuation.yield(self.status)
        return stream
    }

    /// Direct-click open. Phase 1 never opens automatically.
    func notchOpen() {
        self.status = .open
    }

    /// Local close action returning to the neutral collapsed state.
    func notchClose() {
        self.status = .closed
    }

    // MARK: Private

    private var statusContinuation: AsyncStream<NotchStatus>.Continuation?
}
