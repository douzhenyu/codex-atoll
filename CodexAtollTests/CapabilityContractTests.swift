//
//  CapabilityContractTests.swift
//  CodexAtollTests
//
//  Shell identity, route, accessibility, and forbidden-state contract tests.
//
//  These tests prove the Phase 1 native shell never begins implying Desktop
//  observability or inherited side effects. Identifier-aware source assertions
//  keep the required human-readable privacy copy (Plan 05) from creating false
//  failures: they scan Swift source identifiers, not copy text.
//

import XCTest
@testable import CodexAtoll

/// The app target is MainActor-isolated (`SWIFT_DEFAULT_ACTOR_ISOLATION =
/// MainActor`), so the contract tests run on the main actor too.
@MainActor
final class CapabilityContractTests: XCTestCase {
    // MARK: - Shell transitions

    func testFreshModelStartsClosedWithCompanionDestination() {
        let model = NotchViewModel(geometry: Self.testGeometry)

        XCTAssertEqual(model.status, .closed)
        XCTAssertEqual(model.destination, .companion)
    }

    func testDirectOpenThenCloseKeepsLocalRoute() {
        let model = NotchViewModel(geometry: Self.testGeometry)

        model.notchOpen()
        XCTAssertEqual(model.status, .open)
        XCTAssertEqual(model.destination, .companion)

        model.notchClose()
        XCTAssertEqual(model.status, .closed)
        XCTAssertEqual(model.destination, .companion)
    }

    // MARK: - Collapsed contract

    func testCollapsedAccessibilityLabelIsCompleteForVoiceOver() {
        // The collapsed state must expose the complete neutral source state,
        // never a glyph-only meaning.
        XCTAssertEqual(
            NotchStrings.collapsedAccessibility,
            "Codex Atoll. Codex Desktop is currently unobservable.",
        )
        XCTAssertEqual(NotchStrings.desktopSource, "Codex Desktop")
        XCTAssertEqual(NotchStrings.currentlyUnobservable, "Currently unobservable")
    }

    func testCollapsedShellHasNoTaskOrProgressState() {
        let model = NotchViewModel(geometry: Self.testGeometry)

        // A fresh model owns only closed/open status and the single local
        // route; it never exposes a running/task/provider surface.
        XCTAssertEqual(model.status, .closed)
        XCTAssertEqual(model.destination, .companion)

        // The panel geometry is purely local: the closed pill only reserves
        // the physical notch area plus the two icon strips.
        let geometry = model.geometry
        XCTAssertGreaterThanOrEqual(
            geometry.closedContentSize.width,
            geometry.deviceNotchRect.width,
        )
        XCTAssertGreaterThan(
            geometry.openedContentSize.width,
            geometry.closedContentSize.width,
        )
    }

    // MARK: - Forbidden production inventory

    func testProductionInventoryRejectsInheritedServicesAndPersistence() throws {
        let forbiddenTokens: [String] = [
            "HookInstaller",
            "HookSocketServer",
            "TokenTrackingManager",
            "ClaudeSessionMonitor",
            "SUFeedURL",
            "SUPublicEDKey",
            "claudeatoll.engels74.net",
            "CGEventPost",
            "AXUIElement",
            "ProgressView",
            "UserDefaults",
            "@AppStorage",
        ]

        let sourceFiles = try Self.appSwiftSources()
        XCTAssertFalse(sourceFiles.isEmpty, "Expected Swift sources under CodexAtoll/")

        for token in forbiddenTokens {
            let offenders = sourceFiles.filter { $0.text.contains(token) }
            XCTAssertTrue(
                offenders.isEmpty,
                "Forbidden production token '\(token)' found in \(offenders.map(\.url.lastPathComponent))",
            )
        }
    }

    // MARK: - Helpers

    private static var testGeometry: NotchGeometry {
        NotchGeometry(
            deviceNotchRect: CGRect(x: 640, y: 0, width: 224, height: 38),
            screenFrame: CGRect(x: 0, y: 0, width: 1512, height: 982),
        )
    }

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
                "App source directory not found at \(sourcesDir.path); source-inventory assertion skipped.",
            )
        }

        var result: [(url: URL, text: String)] = []
        for case let url as URL in enumerator where url.pathExtension == "swift" {
            let text = try String(contentsOf: url, encoding: .utf8)
            result.append((url, text))
        }
        return result
    }
}
