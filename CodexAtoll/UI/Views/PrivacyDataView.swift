//
//  PrivacyDataView.swift
//  CodexAtoll
//
//  Always-accessible Privacy & Data page.
//
//  Phase 1 keeps every integration disabled, so this page is an informational
//  pre-enable disclosure: the exact empty state plus the complete ordered
//  data-boundary template. It receives no credential, account, session,
//  database, monitor, or mutable consent dependency and offers no live enable
//  toggle or persisted disclosure state (D-12 through D-16).
//

import SwiftUI

// MARK: - PrivacyStrings

/// Localized copy for the Privacy & Data page. Values come from
/// Localizable.xcstrings; the en values match the UI-SPEC privacy contract so
/// tests stay readable.
enum PrivacyStrings {
    static let title = String(localized: "Privacy & Data")
    static let emptyState = String(localized: "No integrations are enabled")
    static let emptyBody = String(localized: "Codex Atoll is not monitoring Codex. Before an integration is enabled, you can review exactly what data it may process.")
    static let whatMayBeProcessedTitle = String(localized: "What an integration may process")
    static let controlTitle = String(localized: "Your control")
    static let controlBody = String(localized: "Integrations are off by default, authorized independently, and revocable at any time. You can clear Codex Atoll-owned local data without affecting Codex or ChatGPT.")
    static let credentialTitle = String(localized: "Credentials and private data")
    static let credentialAssurance = String(localized: "Codex Atoll never asks for your Codex OAuth token, session cookie, or Keychain credential.")
    static let exclusionDesktopDatabase = String(localized: "Codex Atoll does not read ChatGPT or Codex Desktop private databases.")
    static let exclusionScrapedTaskData = String(localized: "Codex Atoll does not read UI-scraped task data.")
    static let disclosureFailureTitle = String(localized: "Before enabling an integration")
    static let disclosureFailureContract = String(localized: "If enabling an integration fails, the disclosure sheet stays open, names the integration, explains the failure, and leaves consent off.")
}

// MARK: - DisclosureCategory

/// The ordered set of disclosure rows shown on the Privacy & Data page.
///
/// Order is part of the Phase 1 contract and is tested exactly: integration
/// identity, prompt text, tool calls and results, session/status metadata,
/// processing location, then retention. The prompt/tool/session data rows each
/// resolve their own processing-location and retention statements (D-13) so
/// they are never merged into a vague data label.
enum DisclosureCategory: CaseIterable, Hashable, Sendable {
    case integrationIdentity
    case promptText
    case toolCallsResults
    case sessionStatusMetadata
    case processingLocation
    case retention

    /// The data rows that must each carry their own processing-location and
    /// retention statements (D-13).
    static let dataCategories: [DisclosureCategory] = [
        .promptText,
        .toolCallsResults,
        .sessionStatusMetadata,
    ]

    /// Literal localized row title.
    var title: String {
        switch self {
        case .integrationIdentity:
            String(localized: "Integration identity")
        case .promptText:
            String(localized: "Prompt text")
        case .toolCallsResults:
            String(localized: "Tool calls and results")
        case .sessionStatusMetadata:
            String(localized: "Session/status metadata")
        case .processingLocation:
            String(localized: "Processing location")
        case .retention:
            String(localized: "Retention")
        }
    }

    /// Literal localized row body describing the category.
    var body: String {
        switch self {
        case .integrationIdentity:
            String(localized: "The integration being considered and the provider that would receive data.")
        case .promptText:
            String(localized: "Prompts and instructions you send while the integration is active.")
        case .toolCallsResults:
            String(localized: "Tool invocations the integration makes and their returned results.")
        case .sessionStatusMetadata:
            String(localized: "Timestamps and status changes that describe when work happened.")
        case .processingLocation:
            String(localized: "Where each category above is processed and who can access it.")
        case .retention:
            String(localized: "How long each category above is kept.")
        }
    }

    /// Literal localized processing-location statement for this row (D-13).
    var location: String {
        switch self {
        case .integrationIdentity:
            String(localized: "Stored locally in Codex Atoll; shared only after you enable the integration.")
        case .promptText, .toolCallsResults, .sessionStatusMetadata:
            String(localized: "Sent to the integration provider you authorize; never stored by Codex Atoll.")
        case .processingLocation:
            String(localized: "On device in Codex Atoll while no integration is enabled; by a provider only after you authorize it.")
        case .retention:
            String(localized: "Stated per integration immediately before you enable it.")
        }
    }

    /// Literal localized retention statement for this row (D-13).
    var retention: String {
        switch self {
        case .integrationIdentity:
            String(localized: "Retained only while the integration stays enabled.")
        case .promptText, .toolCallsResults, .sessionStatusMetadata:
            String(localized: "Retained for the period the integration provider documents.")
        case .processingLocation:
            String(localized: "Stated again immediately before you enable an integration.")
        case .retention:
            String(localized: "Disclosed before enabling and again on revocation.")
        }
    }
}

// MARK: - PrivacyDataView

/// The always-accessible privacy boundary. Informational in Phase 1: it owns
/// no credential, account, session, database, monitor, or mutable consent
/// dependency and offers no live enable action.
struct PrivacyDataView: View {
    // MARK: Lifecycle

    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    // MARK: Internal

    let onBack: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                self.backButton
                self.heading
                self.emptyStateCard
                self.categoriesSection
                self.controlSection
                self.credentialSection
                self.backstopNote
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Complete VoiceOver label for one disclosure row: title, body, processing
    /// location, and retention are all announced so no meaning hides behind a
    /// decorative glyph or truncated text.
    static func categoryAccessibilityLabel(for category: DisclosureCategory) -> String {
        [category.title, category.body, category.location, category.retention]
            .joined(separator: ". ")
    }

    // MARK: Private

    private var backButton: some View {
        Button(action: self.onBack) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12))
                    .accessibilityHidden(true)
                Text(NotchStrings.back)
                    .font(.system(size: 14))
            }
            .foregroundColor(.white.opacity(0.8))
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var heading: some View {
        Text(PrivacyStrings.title)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.white)
            .accessibilityAddTraits(.isHeader)
    }

    private var emptyStateCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(PrivacyStrings.emptyState)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Text(PrivacyStrings.emptyBody)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Self.sectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(PrivacyStrings.whatMayBeProcessedTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)
            ForEach(DisclosureCategory.allCases, id: \.self) { category in
                self.categoryRow(category)
            }
        }
    }

    private func categoryRow(_ category: DisclosureCategory) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Text(category.body)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
            Divider()
                .background(Color.white.opacity(0.08))
            self.metadataLine(icon: "location", text: category.location)
            self.metadataLine(icon: "clock", text: category.retention)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Self.sectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Self.categoryAccessibilityLabel(for: category))
    }

    private func metadataLine(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
                .accessibilityHidden(true)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var controlSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(PrivacyStrings.controlTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)
            Text(PrivacyStrings.controlBody)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Self.sectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }

    private var credentialSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(PrivacyStrings.credentialTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)
            Text(PrivacyStrings.credentialAssurance)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
            self.metadataLine(icon: "xmark.shield", text: PrivacyStrings.exclusionDesktopDatabase)
            self.metadataLine(icon: "xmark.shield", text: PrivacyStrings.exclusionScrapedTaskData)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Self.sectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }

    /// Records the held-out UI backstop: the phase that introduces enablement
    /// must keep its disclosure sheet open, name the integration, explain the
    /// failure, and leave consent off on a failed enable action.
    private var backstopNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(PrivacyStrings.disclosureFailureTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)
            Text(PrivacyStrings.disclosureFailureContract)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Self.sectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }

    /// UI-SPEC secondary surface color (#1C1C1E).
    private static let sectionBackground = Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
}
