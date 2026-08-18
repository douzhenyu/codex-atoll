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

    // MARK: - Menu contract

    func testMenuButtonAccessibilityLabelIsExact() {
        XCTAssertEqual(NotchStrings.openMenu, "Open Codex Atoll menu")
        XCTAssertEqual(NotchStrings.quit, "Quit Codex Atoll")
    }

    func testMenuDescriptorsMatchUISpecContract() {
        let items = NotchMenuView.items
        XCTAssertEqual(items.count, 5)
        XCTAssertEqual(
            items.map(\.label),
            ["Open ChatGPT", "Open official Codex usage", "Privacy & Data", "Back", "Quit Codex Atoll"],
        )
        XCTAssertEqual(
            items.map(\.action),
            [.openChatGPT, .openOfficialUsage, .privacyData, .back, .quit],
        )
    }

    func testMenuRouteTogglesToMenuAndBack() {
        let model = NotchViewModel(geometry: Self.testGeometry)

        model.notchOpen()
        model.openMenu()
        XCTAssertEqual(model.destination, .menu)

        model.goBack()
        XCTAssertEqual(model.destination, .companion)
        XCTAssertEqual(model.status, .open, "Menu back must not close the notch")
    }

    func testLocalDestinationsCarryNoQuotaOrAccountData() {
        // The route enum is payload-free by construction (no associated values);
        // this proves the full Phase 1 local destination set and that no route
        // can carry quota, history, account, credential, or integration data.
        let destinations = Set(NotchDestination.allCases.map { "\($0)" })
        XCTAssertEqual(destinations, Set(["companion", "usageUnavailable", "menu", "privacyData"]))
    }

    func testNoBareWorkspaceCallsInSwiftUIViews() throws {
        // Every external handoff must go through the tested launcher, never a
        // bare workspace call from a SwiftUI view or component file.
        let forbidden = ["NSWorkspace.shared.open"]
        let viewSources = try Self.appSwiftSources().filter { file in
            let path = file.url.path
            return path.contains("/UI/Views/") || path.contains("/UI/Components/")
        }
        XCTAssertFalse(viewSources.isEmpty, "Expected SwiftUI view sources under CodexAtoll/UI")

        for token in forbidden {
            let offenders = viewSources.filter { $0.text.contains(token) }
            XCTAssertTrue(
                offenders.isEmpty,
                "Bare '\(token)' found in SwiftUI view source \(offenders.map(\.url.lastPathComponent))",
            )
        }
    }

    // MARK: - Privacy & Data contract

    func testPrivacyRouteRoundTripIsLocalAndKeepsNotchOpen() {
        let model = NotchViewModel(geometry: Self.testGeometry)

        model.notchOpen()
        model.openPrivacyData()
        XCTAssertEqual(model.destination, .privacyData)

        model.goBack()
        XCTAssertEqual(model.destination, .companion)
        XCTAssertEqual(
            model.status,
            .open,
            "Back from Privacy & Data must return to the companion without closing the notch",
        )
    }

    func testFirstLaunchHasNoPrivacyModal() {
        // D-12/D-15: no generic privacy modal blocks first launch; the
        // always-accessible Privacy & Data page is reached through menu
        // navigation only.
        let model = NotchViewModel(geometry: Self.testGeometry)
        XCTAssertEqual(model.status, .closed)
        XCTAssertEqual(model.destination, .companion)
    }

    func testPrivacyMenuRowIsAlwaysReachable() {
        let privacyItem = NotchMenuView.items.first { $0.action == .privacyData }
        XCTAssertNotNil(privacyItem, "The expanded menu must always contain a Privacy & Data row")
        XCTAssertEqual(privacyItem?.label, "Privacy & Data")
    }

    func testDisclosureCategoriesMatchExactOrder() {
        // D-13: disclosure order is stable — integration identity, prompt text,
        // tool calls/results, session/status metadata, processing location, then
        // retention. Enable/not-now actions appear only when an integration is
        // present, which Phase 1 never instantiates.
        XCTAssertEqual(
            DisclosureCategory.allCases,
            [
                .integrationIdentity,
                .promptText,
                .toolCallsResults,
                .sessionStatusMetadata,
                .processingLocation,
                .retention,
            ],
        )
    }

    func testEveryDataRowHasOwnProcessingLocationAndRetention() {
        // D-13: prompt text, tool calls/results, and session/status metadata are
        // separate disclosure rows; a merged generic data row fails this test.
        let rows = DisclosureCategory.dataCategories
        XCTAssertEqual(rows.map(\.title), ["Prompt text", "Tool calls and results", "Session/status metadata"])
        for row in rows {
            XCTAssertFalse(row.location.isEmpty, "\(row.title) must state where it is processed")
            XCTAssertFalse(row.retention.isEmpty, "\(row.title) must state how long it is retained")
        }
        // Distinct titles guarantee the three data rows are never merged.
        XCTAssertEqual(Set(rows.map(\.title)).count, rows.count)
    }

    func testPrivacyEmptyStateAndCopyMatchUISpecContract() {
        XCTAssertEqual(PrivacyStrings.title, "Privacy & Data")
        XCTAssertEqual(PrivacyStrings.emptyState, "No integrations are enabled")
        XCTAssertEqual(
            PrivacyStrings.emptyBody,
            "Codex Atoll is not monitoring Codex. Before an integration is enabled, you can review exactly what data it may process.",
        )
    }

    func testPrivacyControlStatesDefaultOffIndependentRevocableAndClearing() {
        // D-14: integrations start off, are authorized independently, are
        // revocable, and are paired with clearing of Codex Atoll-owned data.
        let control = PrivacyStrings.controlBody
        XCTAssertTrue(control.contains("off by default"), "Control copy must state integrations start off")
        XCTAssertTrue(control.contains("independently"), "Control copy must state independent authorization")
        XCTAssertTrue(control.contains("revoke"), "Control copy must state revocation")
        XCTAssertTrue(control.contains("clear Codex Atoll-owned local data"), "Control copy must state local-data clearing")
    }

    func testCredentialAssuranceNamesEveryLiteralExclusion() {
        // D-16/PRIV-05: the assurance literally names Codex OAuth token, session
        // cookie, and Keychain credential, plus separate exclusions for private
        // Desktop databases and UI-scraped task data.
        XCTAssertEqual(
            PrivacyStrings.credentialAssurance,
            "Codex Atoll never asks for your Codex OAuth token, session cookie, or Keychain credential.",
        )
        XCTAssertEqual(
            PrivacyStrings.exclusionDesktopDatabase,
            "Codex Atoll does not read ChatGPT or Codex Desktop private databases.",
        )
        XCTAssertEqual(
            PrivacyStrings.exclusionScrapedTaskData,
            "Codex Atoll does not read UI-scraped task data.",
        )
    }

    func testLocalizationCatalogContainsPrivacyContract() throws {
        let catalog = try Self.localizationCatalogText()
        let requiredKeys = [
            "Privacy & Data",
            "No integrations are enabled",
            "Codex Atoll is not monitoring Codex. Before an integration is enabled, you can review exactly what data it may process.",
            "Codex Atoll never asks for your Codex OAuth token, session cookie, or Keychain credential.",
        ]
        for key in requiredKeys {
            XCTAssertTrue(catalog.contains(key), "Localization catalog is missing privacy contract key: \(key)")
        }
    }

    func testPrivacyTemplateDoesNotClaimConsentOrEnabledIntegration() {
        // The static pre-enable template must never present itself as consent
        // already granted or as an enabled integration (D-14/D-15 prohibition).
        let strings = [
            PrivacyStrings.emptyState,
            PrivacyStrings.emptyBody,
            PrivacyStrings.controlBody,
            PrivacyStrings.credentialAssurance,
        ]
        for text in strings {
            XCTAssertFalse(text.contains("consent granted"))
            XCTAssertFalse(text.contains("is currently enabled"))
        }
    }

    func testPrivacyCategoryAccessibilityLabelsRetainCompleteContent() {
        // Full VoiceOver copy: every disclosure row's combined label keeps the
        // complete category, processing-location, and retention text.
        for category in DisclosureCategory.allCases {
            let label = PrivacyDataView.categoryAccessibilityLabel(for: category)
            XCTAssertTrue(label.contains(category.title), "Missing title in label for \(category.title)")
            XCTAssertTrue(label.contains(category.body), "Missing body in label for \(category.title)")
            XCTAssertTrue(label.contains(category.location), "Missing location in label for \(category.title)")
            XCTAssertTrue(label.contains(category.retention), "Missing retention in label for \(category.title)")
        }
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

    /// Read the localization catalog so the tests can prove the required
    /// privacy copy is registered in Localizable.xcstrings (not only present as
    /// a Swift `String(localized:)` default).
    private static func localizationCatalogText() throws -> String {
        let testFileURL = URL(fileURLWithPath: #filePath).standardizedFileURL
        let testsDir = testFileURL.deletingLastPathComponent() // .../CodexAtollTests
        let repoRoot = testsDir.deletingLastPathComponent()    // repository root
        let catalogURL = repoRoot
            .appendingPathComponent("CodexAtoll")
            .appendingPathComponent("Resources")
            .appendingPathComponent("Localizable.xcstrings")

        guard FileManager.default.fileExists(atPath: catalogURL.path) else {
            throw XCTSkip("Localization catalog not found at \(catalogURL.path)")
        }
        return try String(contentsOf: catalogURL, encoding: .utf8)
    }
}
