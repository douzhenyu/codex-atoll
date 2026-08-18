//
//  CapabilityClass.swift
//  CodexAtoll
//
//  Literal whole-card capability vocabulary.
//
//  One capability class applies to an entire card; mixed capabilities are
//  split into separate cards before rendering. Phase 1 renders the Desktop
//  card as `.currentlyUnobservable` only. The other classes exist so the
//  whole-card capability contract is explicit, localized, and testable — they
//  are reserved for later verified/owned sessions.
//

import Foundation

/// A card's single capability class.
enum CapabilityClass: String, CaseIterable, Sendable {
    case available
    case jumpOnly
    case currentlyUnobservable

    /// Literal localized label. Color is supplemental and never the sole
    /// capability signal: the label is always shown next to its icon.
    var label: String {
        switch self {
        case .available:
            String(localized: "Available")
        case .jumpOnly:
            String(localized: "Jump only")
        case .currentlyUnobservable:
            String(localized: "Currently unobservable")
        }
    }

    /// SF Symbol shown beside the literal label.
    var systemImage: String {
        switch self {
        case .available:
            "checkmark.circle"
        case .jumpOnly:
            "arrow.up.right.square"
        case .currentlyUnobservable:
            "eye.slash"
        }
    }
}
