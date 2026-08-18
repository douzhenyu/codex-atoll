//
//  DesktopHandoffLauncherTests.swift
//  CodexAtollTests
//
//  Deterministic coverage of the native ChatGPT activation boundary.
//
//  The launcher asks Launch Services only to activate the fixed registered
//  application; these tests prove lookup/open/activation mapping with a thin
//  workspace fake and never touch a real external app.
//

import AppKit
import XCTest
@testable import CodexAtoll

// MARK: - Workspace fake

/// The thin test double for `WorkspaceOpening`. It deliberately exposes only
/// lookup/open/activate — there is no method for task creation, selection,
/// mutation, input, history, approval, or focus.
@MainActor
private final class WorkspaceFake: WorkspaceOpening {
    var lookupURL: URL?
    var openHandler: ((URL) async throws -> any Activatable)?
    private(set) var lookupCalls: [String] = []
    private(set) var openCalls: [URL] = []

    func urlForApplication(withBundleIdentifier bundleIdentifier: String) -> URL? {
        self.lookupCalls.append(bundleIdentifier)
        return self.lookupURL
    }

    func openApplication(
        at url: URL,
        configuration: NSWorkspace.OpenConfiguration
    ) async throws -> any Activatable {
        self.openCalls.append(url)
        guard let openHandler else {
            throw WorkspaceFakeError.missingHandler
        }
        return try await openHandler(url)
    }
}

@MainActor
private struct FakeApp: Activatable {
    let activateResult: Bool

    func activate() -> Bool {
        self.activateResult
    }
}

private enum WorkspaceFakeError: Error {
    case missingHandler
}

// MARK: - Launcher tests

@MainActor
final class DesktopHandoffLauncherTests: XCTestCase {
    // MARK: - Identifier contract

    func testIdentifierSetIsExactlyTheVerifiedOrderedChatGPTBundle() {
        XCTAssertEqual(DesktopHandoffLauncher.chatGPTBundleIdentifiers, ["com.openai.codex"])
    }

    // MARK: - Result mapping

    func testLookupNilMapsToApplicationUnavailable() async {
        let fake = WorkspaceFake()
        fake.lookupURL = nil

        let launcher = DesktopHandoffLauncher(workspace: fake)
        await launcher.openChatGPT()

        XCTAssertEqual(launcher.state, .failed(.applicationUnavailable))
        XCTAssertEqual(fake.lookupCalls, ["com.openai.codex"])
        XCTAssertTrue(fake.openCalls.isEmpty)
    }

    func testLaunchErrorMapsToLaunchFailed() async {
        let fake = WorkspaceFake()
        fake.lookupURL = URL(string: "file:///Applications/ChatGPT.app")
        fake.openHandler = { _ in throw WorkspaceFakeError.missingHandler }

        let launcher = DesktopHandoffLauncher(workspace: fake)
        await launcher.openChatGPT()

        XCTAssertEqual(launcher.state, .failed(.launchFailed))
        XCTAssertEqual(fake.openCalls.count, 1)
    }

    func testActivationFalseMapsToActivationFailed() async {
        let fake = WorkspaceFake()
        fake.lookupURL = URL(string: "file:///Applications/ChatGPT.app")
        fake.openHandler = { _ in FakeApp(activateResult: false) }

        let launcher = DesktopHandoffLauncher(workspace: fake)
        await launcher.openChatGPT()

        XCTAssertEqual(launcher.state, .failed(.activationFailed))
        XCTAssertEqual(fake.openCalls.count, 1)
    }

    func testActivationSuccessClearsStateWithoutTaskClaim() async {
        let fake = WorkspaceFake()
        fake.lookupURL = URL(string: "file:///Applications/ChatGPT.app")
        fake.openHandler = { _ in FakeApp(activateResult: true) }

        let launcher = DesktopHandoffLauncher(workspace: fake)
        await launcher.openChatGPT()

        // Success proves only macOS accepted/activated the request; the local
        // state clears back to idle and makes no task-focus claim.
        XCTAssertEqual(launcher.state, .idle)
        XCTAssertEqual(fake.openCalls.count, 1)
        XCTAssertEqual(fake.lookupCalls, ["com.openai.codex"])
    }
}
