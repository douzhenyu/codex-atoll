//
//  MenuRow.swift
//  CodexAtoll
//
//  Accessible native menu action row.
//
//  A plain SwiftUI button with a 16px icon, 14px label, at least 44px of hit
//  target, and a complete localized accessibility label. The hover background
//  is a visual affordance only — color never carries meaning alone. Row shape
//  adapted from the Apache-2.0 Claude Atoll menu (see NOTICE).
//

import SwiftUI

struct MenuRow: View {
    // MARK: Lifecycle

    init(
        icon: String,
        label: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void,
    ) {
        self.icon = icon
        self.label = label
        self.isDestructive = isDestructive
        self.action = action
    }

    // MARK: Internal

    let icon: String
    let label: String
    let isDestructive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack(spacing: 10) {
                Image(systemName: self.icon)
                    .font(.system(size: 14))
                    .foregroundColor(self.textColor)
                    .frame(width: 16)
                Text(self.label)
                    .font(.system(size: 14))
                    .foregroundColor(self.textColor)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(self.isHovered ? Color.white.opacity(0.08) : Color.clear),
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { self.isHovered = $0 }
        .frame(minHeight: 44)
        .accessibilityLabel(self.label)
    }

    // MARK: Private

    @State private var isHovered = false

    private var textColor: Color {
        if self.isDestructive {
            return Color(red: 1.0, green: 0.4, blue: 0.4)
        }
        return .white.opacity(self.isHovered ? 1.0 : 0.7)
    }
}
