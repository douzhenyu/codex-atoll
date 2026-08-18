//
//  NotchMenuView.swift
//  CodexAtoll
//
//  Small local navigation/actions menu.
//
//  The menu exposes only product-relevant native rows — `Open ChatGPT`,
//  `Open official Codex usage`, Back, and Quit — each dispatched through the
//  tested launcher/routes so failures stay on their owning surfaces. No
//  monitoring, accessibility-permission, quota-account, update, token, or
//  upstream-project settings are carried over from the reference menu.
//

import SwiftUI

struct NotchMenuView: View {
    /// The action a menu row performs. Kept payload-free and testable.
    enum Action: Equatable, Sendable {
        case openChatGPT
        case openOfficialUsage
        case back
        case quit
    }

    /// A testable, ordered menu row descriptor. Rows render as native buttons
    /// with at least 44x44 hit targets and complete localized labels.
    struct MenuItem: Equatable, Identifiable, Sendable {
        let id: String
        let icon: String
        let label: String
        let action: Action
    }

    static let items: [MenuItem] = [
        MenuItem(id: "open-chatgpt", icon: "message", label: NotchStrings.openChatGPT, action: .openChatGPT),
        MenuItem(id: "open-usage", icon: "arrow.up.right.square", label: NotchStrings.usageCTA, action: .openOfficialUsage),
        MenuItem(id: "back", icon: "chevron.left", label: NotchStrings.back, action: .back),
        MenuItem(id: "quit", icon: "power", label: NotchStrings.quit, action: .quit),
    ]

    // MARK: Lifecycle

    init(
        onBack: @escaping () -> Void,
        onQuit: @escaping () -> Void,
        chatGPTLauncher: DesktopHandoffLauncher = DesktopHandoffLauncher(),
        usageLauncher: DesktopHandoffLauncher = DesktopHandoffLauncher(),
    ) {
        self.onBack = onBack
        self.onQuit = onQuit
        self._chatGPTLauncher = State(initialValue: chatGPTLauncher)
        self._usageLauncher = State(initialValue: usageLauncher)
    }

    // MARK: Internal

    let onBack: () -> Void
    let onQuit: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 8) {
                ForEach(Self.items) { item in
                    self.row(for: item)
                }
                // External-action failures stay on the menu surface with the
                // exact retryable copy; the rows remain actionable.
                if case .failed = self.chatGPTLauncher.state {
                    Text(NotchStrings.desktopHandoffError)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if case .failed = self.usageLauncher.state {
                    Text(NotchStrings.usageHandoffError)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 8)
        }
    }

    /// The row label for a handoff action: the transient `Opening…` text only
    /// while the owning launcher is `.opening`, otherwise the fixed label.
    static func rowLabel(for item: MenuItem, chatGPTState: HandoffState, usageState: HandoffState) -> String {
        switch item.action {
        case .openChatGPT:
            chatGPTState == .opening ? NotchStrings.openingChatGPT : item.label
        case .openOfficialUsage:
            usageState == .opening ? NotchStrings.usageOpening : item.label
        case .back, .quit:
            item.label
        }
    }

    // MARK: Private

    @State private var chatGPTLauncher: DesktopHandoffLauncher
    @State private var usageLauncher: DesktopHandoffLauncher

    private func row(for item: MenuItem) -> some View {
        MenuRow(icon: item.icon, label: Self.rowLabel(
            for: item,
            chatGPTState: self.chatGPTLauncher.state,
            usageState: self.usageLauncher.state,
        )) {
            switch item.action {
            case .openChatGPT:
                Task { await self.chatGPTLauncher.openChatGPT() }
            case .openOfficialUsage:
                Task { await self.usageLauncher.openOfficialUsage() }
            case .back:
                self.onBack()
            case .quit:
                self.onQuit()
            }
        }
    }
}
