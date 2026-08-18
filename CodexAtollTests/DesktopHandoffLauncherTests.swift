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
    var openURLHandler: ((URL) async throws -> Void)?
    private(set) var lookupCalls: [String] = []
    private(set) var openCalls: [URL] = []
    private(set) var openURLCalls: [URL] = []

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

    func open(_ url: URL) async throws {
        self.openURLCalls.append(url)
        guard let openURLHandler else {
            throw WorkspaceFakeError.missingHandler
        }
        try await openURLHandler(url)
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

    // MARK: - Coalescing, timeout, and retry

    func testDuplicateTapDuringOpeningIssuesOneWorkspaceCall() async throws {
        let fake = WorkspaceFake()
        fake.lookupURL = URL(string: "file:///Applications/ChatGPT.app")
        fake.openHandler = { _ in
            // A request that stays in flight until cancelled.
            try await Task.sleep(for: .seconds(30))
            return FakeApp(activateResult: true)
        }
        let launcher = DesktopHandoffLauncher(workspace: fake, timeout: .seconds(5))

        let first = Task { await launcher.openChatGPT() }
        defer { first.cancel() }

        // Wait until the first request is visibly `.opening`.
        let openedDeadline = ContinuousClock.now.advanced(by: .seconds(2))
        while launcher.state != .opening, ContinuousClock.now < openedDeadline {
            try await Task.sleep(for: .milliseconds(5))
        }
        XCTAssertEqual(launcher.state, .opening)

        // A second tap while `.opening` must not issue a second workspace call.
        let second = Task { await launcher.openChatGPT() }
        try? await Task.sleep(for: .milliseconds(100))
        second.cancel()

        XCTAssertEqual(fake.openCalls.count, 1)
    }

    func testHangingRequestTimesOutWithInjectedDuration() async throws {
        let fake = WorkspaceFake()
        fake.lookupURL = URL(string: "file:///Applications/ChatGPT.app")
        fake.openHandler = { _ in
            try await Task.sleep(for: .seconds(30))
            return FakeApp(activateResult: true)
        }
        let launcher = DesktopHandoffLauncher(workspace: fake, timeout: .milliseconds(100))

        let request = Task { await launcher.openChatGPT() }
        defer { request.cancel() }

        // Bounded wait for the injected timeout; the test never sleeps for
        // the production five-second bound.
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        while launcher.state != .failed(.timedOut), ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(10))
        }

        XCTAssertEqual(launcher.state, .failed(.timedOut))
        XCTAssertEqual(fake.openCalls.count, 1)
    }

    func testRetryAfterFailureIsPermitted() async {
        let fake = WorkspaceFake()
        fake.lookupURL = URL(string: "file:///Applications/ChatGPT.app")
        fake.openHandler = { _ in FakeApp(activateResult: false) }

        let launcher = DesktopHandoffLauncher(workspace: fake, timeout: .seconds(5))
        await launcher.openChatGPT()
        XCTAssertEqual(launcher.state, .failed(.activationFailed))

        // Failure leaves `.opening`; a retry is permitted and can succeed.
        fake.openHandler = { _ in FakeApp(activateResult: true) }
        await launcher.openChatGPT()

        XCTAssertEqual(launcher.state, .idle)
        XCTAssertEqual(fake.openCalls.count, 2)
    }

    func testProductionTimeoutIsExactlyFiveSeconds() {
        XCTAssertEqual(DesktopHandoffLauncher.productionTimeout, .seconds(5))
    }

    // MARK: - Official usage handoff

    func testOfficialUsageURLIsExactlyTheFixedOfficialPage() {
        XCTAssertEqual(
            DesktopHandoffLauncher.officialUsageURL.absoluteString,
            "https://chatgpt.com/codex/settings/usage",
        )
    }

    func testOpenOfficialUsageIssuesExactlyOneURLOpen() async {
        let fake = WorkspaceFake()
        fake.openURLHandler = { _ in }

        let launcher = DesktopHandoffLauncher(workspace: fake)
        await launcher.openOfficialUsage()

        XCTAssertEqual(launcher.state, .idle)
        XCTAssertEqual(fake.openURLCalls, [DesktopHandoffLauncher.officialUsageURL])
    }

    func testOpenOfficialUsageURLErrorMapsToLaunchFailed() async {
        let fake = WorkspaceFake()
        fake.openURLHandler = { _ in throw WorkspaceFakeError.missingHandler }

        let launcher = DesktopHandoffLauncher(workspace: fake)
        await launcher.openOfficialUsage()

        XCTAssertEqual(launcher.state, .failed(.launchFailed))
        XCTAssertEqual(fake.openURLCalls.count, 1)
    }

    func testOpenOfficialUsageCoalescesConcurrentTaps() async throws {
        let fake = WorkspaceFake()
        fake.openURLHandler = { _ in
            try await Task.sleep(for: .seconds(30))
        }
        let launcher = DesktopHandoffLauncher(workspace: fake, timeout: .seconds(5))

        let first = Task { await launcher.openOfficialUsage() }
        defer { first.cancel() }

        let openedDeadline = ContinuousClock.now.advanced(by: .seconds(2))
        while launcher.state != .opening, ContinuousClock.now < openedDeadline {
            try await Task.sleep(for: .milliseconds(5))
        }
        XCTAssertEqual(launcher.state, .opening)

        // A second tap while `.opening` must not issue a second URL open.
        let second = Task { await launcher.openOfficialUsage() }
        try? await Task.sleep(for: .milliseconds(100))
        second.cancel()

        XCTAssertEqual(fake.openURLCalls.count, 1)
    }

    func testOpenOfficialUsageTimesOutWithInjectedDuration() async throws {
        let fake = WorkspaceFake()
        fake.openURLHandler = { _ in
            try await Task.sleep(for: .seconds(30))
        }
        let launcher = DesktopHandoffLauncher(workspace: fake, timeout: .milliseconds(100))

        let request = Task { await launcher.openOfficialUsage() }
        defer { request.cancel() }

        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        while launcher.state != .failed(.timedOut), ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(10))
        }

        XCTAssertEqual(launcher.state, .failed(.timedOut))
        XCTAssertEqual(fake.openURLCalls.count, 1)
    }

    func testOpenOfficialUsageRetryAfterFailureIsPermitted() async {
        let fake = WorkspaceFake()
        fake.openURLHandler = { _ in throw WorkspaceFakeError.missingHandler }

        let launcher = DesktopHandoffLauncher(workspace: fake, timeout: .seconds(5))
        await launcher.openOfficialUsage()
        XCTAssertEqual(launcher.state, .failed(.launchFailed))

        fake.openURLHandler = { _ in }
        await launcher.openOfficialUsage()

        XCTAssertEqual(launcher.state, .idle)
        XCTAssertEqual(fake.openURLCalls.count, 2)
    }
}
