//
//  CapabilityBadge.swift
//  CodexAtoll
//
//  Accessible capability badge renderer: SF Symbol plus literal text.
//
//  Color is supplemental and never the sole signal; the icon is decorative
//  (hidden from VoiceOver) and the literal label is always announced.
//

import SwiftUI

/// Renders one capability class as icon plus literal text.
struct CapabilityBadge: View {
    // MARK: Lifecycle

    init(capability: CapabilityClass) {
        self.capability = capability
    }

    // MARK: Internal

    let capability: CapabilityClass

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: self.capability.systemImage)
                .font(.system(size: 12))
                .accessibilityHidden(true)
            Text(self.capability.label)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(self.capabilityColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.06))
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
    }

    // MARK: Private

    private var capabilityColor: Color {
        switch self.capability {
        case .available:
            Color(red: 16 / 255, green: 163 / 255, blue: 127 / 255) // accent
        case .jumpOnly:
            Color.white.opacity(0.7)
        case .currentlyUnobservable:
            Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255) // unavailable semantic
        }
    }
}
