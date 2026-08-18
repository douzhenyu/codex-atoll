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

    // MARK: - Desktop card contract

    func testDesktopCompanionRendersExactlyOneOrderedCard() {
        // The expanded companion always renders exactly one ordered card,
        // even with no task data. It must never become empty or a list.
        let cards = DesktopCompanionView.cards
        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards.first?.source, "Codex Desktop")
    }

    func testDesktopCardCapabilityIsCurrentlyUnobservable() throws {
        let card = try XCTUnwrap(DesktopCompanionView.cards.first)
        XCTAssertEqual(card.capability, .currentlyUnobservable)
        XCTAssertEqual(card.capability.label, "Currently unobservable")
        XCTAssertEqual(card.capability.systemImage, "eye.slash")
    }

    func testDesktopCardCopyMatchesUISpecContract() throws {
        let card = try XCTUnwrap(DesktopCompanionView.cards.first)
        XCTAssertEqual(card.source, "Codex Desktop")
        XCTAssertEqual(
            card.body,
            "Codex Atoll cannot obtain current Codex runtime information. Review task details, history, approvals, and actions in ChatGPT until an official integration is available.",
        )
        XCTAssertEqual(card.action, "Open ChatGPT")
        XCTAssertEqual(card.opening, "Opening ChatGPT…")
        XCTAssertEqual(
            card.error,
            "ChatGPT could not be opened. Open it from Applications, then try again.",
        )
    }

    func testCapabilityClassVocabularyIsComplete() {
        XCTAssertEqual(CapabilityClass.available.label, "Available")
        XCTAssertEqual(CapabilityClass.available.systemImage, "checkmark.circle")
        XCTAssertEqual(CapabilityClass.jumpOnly.label, "Jump only")
        XCTAssertEqual(CapabilityClass.jumpOnly.systemImage, "arrow.up.right.square")
        XCTAssertEqual(CapabilityClass.currentlyUnobservable.label, "Currently unobservable")
        XCTAssertEqual(CapabilityClass.currentlyUnobservable.systemImage, "eye.slash")
    }

    func testOpeningStateBindsOnlyToTransientOpeningText() throws {
        let card = try XCTUnwrap(DesktopCompanionView.cards.first)
        // Only the local action result may show transient `Opening ChatGPT…`;
        // the idle/error/retry surface keeps the exact action label.
        XCTAssertEqual(DesktopCompanionView.ctaTitle(for: .opening, card: card), "Opening ChatGPT…")
        XCTAssertEqual(DesktopCompanionView.ctaTitle(for: .idle, card: card), "Open ChatGPT")
        XCTAssertEqual(
            DesktopCompanionView.ctaTitle(for: .failed(.timedOut), card: card),
            "Open ChatGPT",
        )
    }

    // MARK: - Usage unavailable contract

    func testUsageUnavailableCopyMatchesUISpecContract() {
        XCTAssertEqual(NotchStrings.usageUnavailable, "Usage unavailable")
        XCTAssertEqual(NotchStrings.usageDetailHeading, "Usage details unavailable here")
        XCTAssertEqual(
            NotchStrings.usageDetailBody,
            "Codex Atoll does not read account credentials or estimate your quota. View current limits on the official Codex page.",
        )
        XCTAssertEqual(NotchStrings.usageCTA, "Open official Codex usage")
        XCTAssertEqual(NotchStrings.usageOpening, "Opening official Codex usage…")
        XCTAssertEqual(
            NotchStrings.usageHandoffError,
            "The official Codex usage page could not be opened. Check your default browser, then try again.",
        )
        XCTAssertEqual(NotchStrings.back, "Back")
    }

    func testUsageDetailRouteRoundTripIsLocalAndKeepsNotchOpen() {
        let model = NotchViewModel(geometry: Self.testGeometry)

        model.notchOpen()
        model.openUsageUnavailable()
        XCTAssertEqual(model.destination, .usageUnavailable)

        model.goBack()
        XCTAssertEqual(model.destination, .companion)
        XCTAssertEqual(model.status, .open, "Back must return to the companion without closing the notch")
    }

    func testUsageSurfaceCopyHasNoQuotaOrLoadingPresentation() {
        let usageStrings = [
            NotchStrings.usageUnavailable,
            NotchStrings.usageDetailHeading,
            NotchStrings.usageDetailBody,
            NotchStrings.usageCTA,
            NotchStrings.usageOpening,
            NotchStrings.usageHandoffError,
        ]
        let forbiddenFragments = ["%", "reset", "Remaining", "heatmap", "chart", "skeleton", "progress"]
        for text in usageStrings {
            for fragment in forbiddenFragments {
                XCTAssertFalse(
                    text.localizedCaseInsensitiveContains(fragment),
                    "Usage copy must not present quota or loading data: '\(text)' contains '\(fragment)'",
                )
            }
        }
    }

    func testUsageCtaTitleBindsOnlyToTransientOpeningText() {
        // Only the local action result may show transient `Opening…`; the
        // idle/error/retry surface keeps the exact action label.
        XCTAssertEqual(UsageUnavailableView.ctaTitle(for: .opening), "Opening official Codex usage…")
        XCTAssertEqual(UsageUnavailableView.ctaTitle(for: .idle), "Open official Codex usage")
        XCTAssertEqual(
            UsageUnavailableView.ctaTitle(for: .failed(.timedOut)),
            "Open official Codex usage",
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
            "WKWebView",
            "URLSession",
            "SecItemCopyMatching",
            "ASWebAuthenticationSession",
            "HTTPCookieStorage",
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
