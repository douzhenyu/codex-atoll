//
//  UsageUnavailableView.swift
//  CodexAtoll
//
//  In-notch usage-unavailable detail and official-page handoff.
//
//  Phase 1 has no supported source for authoritative account-wide quota or
//  usage history, so this surface states that boundary honestly, opens only
//  the fixed official Codex usage page in the default browser, and never
//  fetches, embeds, parses, caches, estimates, or retains any page, plan, or
//  account value. No numeric quota, reset time, progress ring, chart, heatmap,
//  skeleton, stale value, or quota-loading indicator is rendered.
//

import SwiftUI

struct UsageUnavailableView: View {
    // MARK: Lifecycle

    init(
        onBack: @escaping () -> Void,
        launcher: DesktopHandoffLauncher = DesktopHandoffLauncher(),
    ) {
        self.onBack = onBack
        self._launcher = State(initialValue: launcher)
    }

    // MARK: Internal

    let onBack: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 16) {
                self.backButton
                self.headingRow
                self.bodyText

                // The official CTA on its own final row; 44px minimum target.
                self.ctaButton

                // Failure retains the detail and shows the exact retryable
                // browser copy.
                if case .failed = self.launcher.state {
                    Text(NotchStrings.usageHandoffError)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    /// The CTA title for a launcher state: the transient `Opening…` text only
    /// while `.opening`, otherwise the fixed action label. No quota or progress
    /// presentation ever replaces the action.
    static func ctaTitle(for state: HandoffState) -> String {
        state == .opening ? NotchStrings.usageOpening : NotchStrings.usageCTA
    }

    // MARK: Private

    @State private var launcher: DesktopHandoffLauncher

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

    private var headingRow: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(NotchStrings.usageDetailHeading)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            CapabilityBadge(capability: .jumpOnly)
            Spacer(minLength: 0)
        }
    }

    private var bodyText: some View {
        Text(NotchStrings.usageDetailBody)
            .font(.system(size: 14))
            .foregroundColor(.white.opacity(0.8))
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(NotchStrings.usageDetailBody)
    }

    private var ctaButton: some View {
        Button {
            Task { await self.launcher.openOfficialUsage() }
        } label: {
            Text(Self.ctaTitle(for: self.launcher.state))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(red: 16 / 255, green: 163 / 255, blue: 127 / 255))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .disabled(self.launcher.state == .opening)
        .frame(minHeight: 44)
    }
}
