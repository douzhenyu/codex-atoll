//
//  DesktopHandoffLauncher.swift
//  CodexAtoll
//
//  Result-bearing native ChatGPT activation boundary.
//
//  The launcher asks Launch Services to open and activate the fixed registered
//  application. Success proves only that macOS accepted and activated the
//  request — it never creates, selects, mutates, focuses, observes, or infers
//  a Desktop task. The path ends at Launch Services: no task id, app deep
//  link, screen element, user input, Desktop store, credentials, network,
//  database, server, authentication, or preference storage crosses it.
//

import AppKit
import Observation

// MARK: - WorkspaceOpening

/// The minimal AppKit surface the launcher depends on: registered-app lookup,
/// open, and activation only. `SystemWorkspace` is the AppKit implementation;
/// test doubles are the only other conformers.
@MainActor
protocol WorkspaceOpening {
    func urlForApplication(withBundleIdentifier bundleIdentifier: String) -> URL?

    func openApplication(
        at url: URL,
        configuration: NSWorkspace.OpenConfiguration
    ) async throws -> any Activatable
}

/// A launched application that can be asked to come to the foreground.
@MainActor
protocol Activatable {
    func activate() -> Bool
}

extension NSRunningApplication: Activatable {
    func activate() -> Bool {
        self.activate(options: [])
    }
}

/// The real Launch Services-backed workspace.
struct SystemWorkspace: WorkspaceOpening {
    func urlForApplication(withBundleIdentifier bundleIdentifier: String) -> URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier)
    }

    func openApplication(
        at url: URL,
        configuration: NSWorkspace.OpenConfiguration
    ) async throws -> any Activatable {
        try await NSWorkspace.shared.openApplication(at: url, configuration: configuration)
    }
}

// MARK: - HandoffState

/// The local activation result surface. There is no running/task/provider
/// state: every failure is actionable and the originating card stays visible.
enum HandoffState: Equatable, Sendable {
    case idle
    case opening
    case failed(HandoffError)
}

/// The exact failure reasons the launcher can produce. All four map to the
/// same localized Applications fallback while preserving the card.
enum HandoffError: Error, Equatable, Sendable {
    case applicationUnavailable
    case launchFailed
    case activationFailed
    case timedOut
}

// MARK: - DesktopHandoffLauncher

/// Bounded, main-actor ChatGPT activation owned by the Desktop card.
@MainActor
@Observable
final class DesktopHandoffLauncher {
    /// Ordered, compile-time identifier set. Only the locally verified
    /// `com.openai.codex` bundle is present; aliases are never guessed.
    static let chatGPTBundleIdentifiers: [String] = ["com.openai.codex"]

    private let workspace: any WorkspaceOpening

    private(set) var state: HandoffState = .idle

    init(workspace: any WorkspaceOpening = SystemWorkspace()) {
        self.workspace = workspace
    }

    /// Ask Launch Services to open and activate the registered ChatGPT app.
    /// Success means only that macOS accepted/activated the request.
    func openChatGPT() async {
        self.state = .opening
        let outcome = await self.performOpen()
        self.finish(outcome)
    }

    // MARK: Private

    private enum Outcome: Equatable, Sendable {
        case success
        case failure(HandoffError)
    }

    private func performOpen() async -> Outcome {
        for bundleIdentifier in Self.chatGPTBundleIdentifiers {
            guard let url = self.workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
                continue
            }
            do {
                let application = try await self.workspace.openApplication(
                    at: url,
                    configuration: .init(),
                )
                guard application.activate() else {
                    return .failure(.activationFailed)
                }
                return .success
            } catch {
                return .failure(.launchFailed)
            }
        }
        return .failure(.applicationUnavailable)
    }

    private func finish(_ outcome: Outcome) {
        switch outcome {
        case .success:
            self.state = .idle
        case let .failure(error):
            self.state = .failed(error)
        }
    }
}
