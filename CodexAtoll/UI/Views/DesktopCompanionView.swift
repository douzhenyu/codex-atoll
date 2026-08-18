//
//  DesktopCompanionView.swift
//  CodexAtoll
//
//  Fixed source-labelled unobservable Desktop card and its only external
//  action: bounded native ChatGPT activation.
//
//  The card is honest by construction: exactly one ordered `Codex Desktop` /
//  `Currently unobservable` card with the exact explanation and CTA. It has
//  no loading skeleton, task spinner, percentage, history, approval, prompt,
//  pause, or timeline.
//

import SwiftUI

// MARK: - DesktopCardModel

/// The single fixed card the companion route renders. Cardinality (exactly
/// one) and ordering are part of the Phase 1 contract and are contract-tested.
struct DesktopCardModel: Equatable, Identifiable {
    let id: String
    let source: String
    let capability: CapabilityClass
    let body: String
    let action: String
    let opening: String
    let error: String
}

// MARK: - DesktopCompanionView

/// The complete honest Desktop card. It has exactly one external action and
/// no status/history/approval/prompt/pause/task-list control.
struct DesktopCompanionView: View {
    /// The one ordered card this route renders, even with no task data.
    static let cards: [DesktopCardModel] = [
        DesktopCardModel(
            id: "codex-desktop-companion",
            source: NotchStrings.desktopSource,
            capability: .currentlyUnobservable,
            body: NotchStrings.desktopBody,
            action: NotchStrings.openChatGPT,
            opening: NotchStrings.openingChatGPT,
            error: NotchStrings.desktopHandoffError,
        ),
    ]

    // MARK: Lifecycle

    init(launcher: DesktopHandoffLauncher = DesktopHandoffLauncher()) {
        self._launcher = State(initialValue: launcher)
    }

    // MARK: Internal

    @State private var launcher: DesktopHandoffLauncher

    var body: some View {
        ForEach(Self.cards) { card in
            self.cardView(for: card)
        }
    }

    /// The CTA title for a launcher state: the transient opening text only
    /// while `.opening`, otherwise the fixed action label. Task-progress and
    /// collapsed activity never appear in place of the action.
    static func ctaTitle(for state: HandoffState, card: DesktopCardModel) -> String {
        state == .opening ? card.opening : card.action
    }

    // MARK: Private

    private func cardView(for card: DesktopCardModel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Source label (compact status role).
            Text(card.source)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))

            // Title plus capability badge.
            HStack(alignment: .center, spacing: 8) {
                Text(card.source)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                CapabilityBadge(capability: card.capability)
                Spacer(minLength: 0)
            }

            // Body: wraps, two-line visual limit, full VoiceOver value.
            Text(card.body)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(2)
                .accessibilityLabel(card.body)

            // Primary CTA on its own final row; 44px minimum target.
            Button {
                Task { await self.launcher.openChatGPT() }
            } label: {
                Text(Self.ctaTitle(for: self.launcher.state, card: card))
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

            // Failure keeps the card and explanation visible and shows the
            // exact retryable Applications copy.
            if case .failed = self.launcher.state {
                Text(card.error)
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
