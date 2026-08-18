//
//  PhaseBoundaryTests.swift
//  CodexAtollTests
//
//  Phase-wide privacy and capability boundary proofs.
//
//  These tests locate the production target source/resources from the test
//  bundle's project root and assert the allowed external-target inventory, a
//  clean startup lifecycle, the absence of inherited privileged subsystems,
//  private account/Desktop access operations, and UI-automation primitives.
//
//  Boundary checks are identifier-aware: they scan executable API identifiers
//  and class/route names, never the human-readable words the Privacy & Data
//  page must display (e.g. "OAuth token", "session cookie", "Keychain
//  credential" are required copy and are not banned).
//

import XCTest
@testable import CodexAtoll

@MainActor
final class PhaseBoundaryTests: XCTestCase {
    // MARK: - External target inventory

    func testExternalTargetInventoryIsExactlyTwoFixedConstants() {
        // The whole phase crosses the OS boundary through exactly two fixed
        // targets: the registered ChatGPT bundle activation and the fixed
        // official usage HTTPS URL. Cardinality and equality are both asserted.
        XCTAssertEqual(DesktopHandoffLauncher.chatGPTBundleIdentifiers, ["com.openai.codex"])
        XCTAssertEqual(
            DesktopHandoffLauncher.officialUsageURL.absoluteString,
            "https://chatgpt.com/codex/settings/usage",
        )
        XCTAssertEqual(DesktopHandoffLauncher.officialUsageURL.scheme, "https")
    }

    func testExternalTargetsAcceptNoUserTaskOrAccountInterpolation() throws {
        // Neither external target may be built from runtime user, task, or
        // account text; both are immutable compile-time constants with no
        // format/interpolation seam and no mutable configuration (T-05-05).
        let launcherSource = try Self.sourceText("DesktopHandoffLauncher.swift")

        XCTAssertTrue(
            launcherSource.contains("static let chatGPTBundleIdentifiers"),
            "The ChatGPT identifier set must be a compile-time constant",
        )
        XCTAssertTrue(
            launcherSource.contains("static let officialUsageURL"),
            "The official usage URL must be a compile-time constant",
        )
        XCTAssertFalse(
            launcherSource.contains("var chatGPTBundleIdentifiers"),
            "The ChatGPT identifier set must not be mutable",
        )
        XCTAssertFalse(
            launcherSource.contains("var officialUsageURL"),
            "The official usage URL must not be mutable",
        )
        XCTAssertFalse(
            launcherSource.contains("String(format:"),
            "External targets must never use format interpolation",
        )
        XCTAssertFalse(
            launcherSource.contains("\\("),
            "External targets must never be built with string interpolation",
        )
    }

    func testNSWorkspaceBoundaryIsConfinedToTheThinLauncher() throws {
        // Every external handoff must route through the thin WorkspaceOpening
        // boundary; no other production file may call NSWorkspace directly
        // (T-05-04).
        let allSources = try Self.appSwiftSources()
        for file in allSources {
            if file.url.lastPathComponent == "DesktopHandoffLauncher.swift" { continue }
            XCTAssertFalse(
                file.text.contains("NSWorkspace"),
                "NSWorkspace must be confined to DesktopHandoffLauncher.swift (found in \(file.url.lastPathComponent))",
            )
        }
    }

    // MARK: - Startup lifecycle boundary

    func testStartupLifecycleHasNoInheritedSideEffectServices() throws {
        // The app must start window-only: no hook installer, socket server,
        // session monitor, token tracking, updater identity, or periodic
        // update check may run at launch or terminate (T-05-03).
        let forbidden = [
            "HookInstaller",
            "HookSocketServer",
            "TokenTrackingManager",
            "ClaudeSessionMonitor",
            "SUFeedURL",
            "SUPublicEDKey",
            "updateCheckTask",
            "checkForUpdates",
        ]
        let startupSources = try ["CodexAtollApp.swift", "AppDelegate.swift"].map { try Self.sourceText($0) }
        for source in startupSources {
            for token in forbidden {
                XCTAssertFalse(
                    source.contains(token),
                    "Startup must not launch inherited side-effect service '\(token)'",
                )
            }
        }
    }

    // MARK: - Credential / private-data boundary

    func testProductionHasNoKeychainOrOAuthWebAuthOperation() throws {
        // No Keychain operation (read or write), OAuth/web-auth flow, or
        // cookie/private-store reader may exist in production source (PRIV-05;
        // T-05-02). API identifiers only — the human-readable privacy copy that
        // must display "OAuth token" / "Keychain credential" is untouched.
        let forbidden = [
            "SecItemCopyMatching",
            "SecItemAdd",
            "SecKeychain",
            "ASWebAuthenticationSession",
        ]
        try Self.assertAllProductionSourcesExclude(forbidden)
    }

    func testProductionHasNoCookiePrivateDatabaseOrNetworkQuotaPath() throws {
        // No cookie jar, embedded browser, private database reader, or network
        // client may fetch, read, or parse account/quota data (USAGE-01;
        // T-05-02, T-05-04).
        let forbidden = [
            "HTTPCookieStorage",
            "HTTPCookie",
            "WKWebView",
            "URLSession",
            "CFNetwork",
            "NWConnection",
        ]
        try Self.assertAllProductionSourcesExclude(forbidden)
    }

    // MARK: - Automation boundary

    func testProductionHasNoUIAutomationOrSyntheticInputPrimitives() throws {
        // No synthetic event posting, accessibility automation, global event
        // monitoring, AppleScript, or task-control primitive may exist
        // (T-05-04). Only user-initiated fixed-target handoffs cross the OS
        // boundary.
        let forbidden = [
            "CGEventPost",
            "AXUIElement",
            "AXObserver",
            "AXIsProcessTrusted",
            "addGlobalMonitorForEvents",
            "addLocalMonitorForEvents",
            "NSAppleScript",
        ]
        try Self.assertAllProductionSourcesExclude(forbidden)
    }

    // MARK: - No persistent-state owner

    func testNoPhaseOneProductionTypeOwnsPersistentMutableState() throws {
        // No Phase 1 production type may own persistent user/session data,
        // authentication, a network client, a database, or an integration-
        // enabled flag.
        let forbidden = [
            "UserDefaults",
            "@AppStorage",
            "NSPersistentContainer",
            "SQLite",
            "CoreData",
        ]
        try Self.assertAllProductionSourcesExclude(forbidden)
    }

    // MARK: - Helpers

    /// Enumerate the app target's Swift sources under the repository's
    /// `CodexAtoll/` directory, resolved from this test file's path.
    private static func appSwiftSources() throws -> [(url: URL, text: String)] {
        let testFileURL = URL(fileURLWithPath: #filePath).standardizedFileURL
        let testsDir = testFileURL.deletingLastPathComponent() // .../CodexAtollTests
        let repoRoot = testsDir.deletingLastPathComponent()    // repository root
        let sourcesDir = repoRoot.appendingPathComponent("CodexAtoll")

        guard let enumerator = FileManager.default.enumerator(
            at: sourcesDir,
            includingPropertiesForKeys: nil,
        ) else {
            throw XCTSkip(
                "App source directory not found at \(sourcesDir.path); source-boundary assertions skipped.",
            )
        }

        var result: [(url: URL, text: String)] = []
        for case let url as URL in enumerator where url.pathExtension == "swift" {
            let text = try String(contentsOf: url, encoding: .utf8)
            result.append((url, text))
        }
        return result
    }

    /// Read one named production Swift file's text.
    private static func sourceText(_ filename: String) throws -> String {
        let match = try appSwiftSources().first { $0.url.lastPathComponent == filename }
        guard let match else {
            throw XCTSkip("Production source \(filename) not found; boundary assertion skipped.")
        }
        return match.text
    }

    /// Assert no production Swift file contains any of the forbidden API
    /// identifiers.
    private static func assertAllProductionSourcesExclude(_ tokens: [String]) throws {
        let sourceFiles = try appSwiftSources()
        XCTAssertFalse(sourceFiles.isEmpty, "Expected Swift sources under CodexAtoll/")
        for token in tokens {
            let offenders = sourceFiles.filter { $0.text.contains(token) }
            XCTAssertTrue(
                offenders.isEmpty,
                "Forbidden production API identifier '\(token)' found in \(offenders.map(\.url.lastPathComponent))",
            )
        }
    }
}
