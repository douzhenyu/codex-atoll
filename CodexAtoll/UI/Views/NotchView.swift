//
//  NotchView.swift
//  CodexAtoll
//
//  Collapsed pill and expanded companion shell.
//
//  Adapted from the Apache-2.0 Claude Atoll shell (see NOTICE): the shape and
//  shell composition are kept, while session-derived content is replaced by a
//  fixed, source-labelled companion destination. No spinner, progress ring,
//  approval badge, task list, or inferred Desktop lifecycle state is rendered.
//

import SwiftUI

// MARK: - NotchShape

/// Accurate notch shape using quadratic curves.
struct NotchShape: Shape {
    // MARK: Lifecycle

    init(
        topCornerRadius: CGFloat = 6,
        bottomCornerRadius: CGFloat = 14,
    ) {
        self.topCornerRadius = topCornerRadius
        self.bottomCornerRadius = bottomCornerRadius
    }

    // MARK: Internal

    var topCornerRadius: CGFloat
    var bottomCornerRadius: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
            .init(self.topCornerRadius, self.bottomCornerRadius)
        }
        set {
            self.topCornerRadius = newValue.first
            self.bottomCornerRadius = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        self.addTopLeftCorner(to: &path, rect: rect)
        self.addLeftEdge(to: &path, rect: rect)
        self.addBottomLeftCorner(to: &path, rect: rect)
        self.addBottomEdge(to: &path, rect: rect)
        self.addBottomRightCorner(to: &path, rect: rect)
        self.addRightEdge(to: &path, rect: rect)
        self.addTopRightCorner(to: &path, rect: rect)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        return path
    }

    // MARK: Private

    private func addTopLeftCorner(to path: inout Path, rect: CGRect) {
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + self.topCornerRadius, y: rect.minY + self.topCornerRadius),
            control: CGPoint(x: rect.minX + self.topCornerRadius, y: rect.minY),
        )
    }

    private func addLeftEdge(to path: inout Path, rect: CGRect) {
        path.addLine(to: CGPoint(x: rect.minX + self.topCornerRadius, y: rect.maxY - self.bottomCornerRadius))
    }

    private func addBottomLeftCorner(to path: inout Path, rect: CGRect) {
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + self.topCornerRadius + self.bottomCornerRadius, y: rect.maxY),
            control: CGPoint(x: rect.minX + self.topCornerRadius, y: rect.maxY),
        )
    }

    private func addBottomEdge(to path: inout Path, rect: CGRect) {
        path.addLine(to: CGPoint(x: rect.maxX - self.topCornerRadius - self.bottomCornerRadius, y: rect.maxY))
    }

    private func addBottomRightCorner(to path: inout Path, rect: CGRect) {
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - self.topCornerRadius, y: rect.maxY - self.bottomCornerRadius),
            control: CGPoint(x: rect.maxX - self.topCornerRadius, y: rect.maxY),
        )
    }

    private func addRightEdge(to path: inout Path, rect: CGRect) {
        path.addLine(to: CGPoint(x: rect.maxX - self.topCornerRadius, y: rect.minY + self.topCornerRadius))
    }

    private func addTopRightCorner(to path: inout Path, rect: CGRect) {
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.maxX - self.topCornerRadius, y: rect.minY),
        )
    }
}

// MARK: - NotchStrings

/// Localized shell copy. Values come from Localizable.xcstrings; the en
/// values match the UI-SPEC copy contract so tests stay readable.
enum NotchStrings {
    static let appName = String(localized: "Codex Atoll")
    static let desktopSource = String(localized: "Codex Desktop")
    static let currentlyUnobservable = String(localized: "Currently unobservable")
    static let collapsedAccessibility = String(localized: "Codex Atoll. Codex Desktop is currently unobservable.")
    static let desktopBody = String(localized: "Codex Atoll cannot obtain current Codex runtime information. Review task details, history, approvals, and actions in ChatGPT until an official integration is available.")
    static let closeHint = String(localized: "Click to close")
}

// MARK: - NotchView

struct NotchView: View {
    // MARK: Lifecycle

    init(viewModel: NotchViewModel) {
        self.viewModel = viewModel
    }

    // MARK: Internal

    /// View model is @Observable, so SwiftUI tracks property access.
    var viewModel: NotchViewModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            self.notchPanel
            if self.viewModel.status == .open {
                self.companionContent
                    .transition(.opacity)
            }
        }
        .background(.black)
        .clipShape(self.currentShape)
        .frame(width: self.contentSize.width, height: self.contentSize.height, alignment: .top)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .preferredColorScheme(.dark)
        .animation(.easeOut(duration: 0.25), value: self.viewModel.status)
        .onExitCommand {
            self.viewModel.notchClose()
        }
    }

    // MARK: Private

    // Corner radii
    private static let closedTopCornerRadius: CGFloat = 6
    private static let closedBottomCornerRadius: CGFloat = 14
    private static let openedTopCornerRadius: CGFloat = 19
    private static let openedBottomCornerRadius: CGFloat = 24

    // Layout constants shared with NotchGeometry
    private static let interModuleSpacing: CGFloat = NotchGeometry.closedInterModuleSpacing
    private static let iconStripWidth: CGFloat = NotchGeometry.closedIconStripWidth
    private static let edgeInset: CGFloat = NotchGeometry.closedEdgeInset

    private var closedHeight: CGFloat {
        max(self.viewModel.geometry.deviceNotchRect.height, NotchGeometry.minimumClosedHeight)
    }

    private var contentSize: CGSize {
        switch self.viewModel.status {
        case .closed:
            self.viewModel.geometry.closedContentSize
        case .open:
            self.viewModel.geometry.openedContentSize
        }
    }

    private var currentShape: NotchShape {
        switch self.viewModel.status {
        case .closed:
            NotchShape(
                topCornerRadius: Self.closedTopCornerRadius,
                bottomCornerRadius: Self.closedBottomCornerRadius,
            )
        case .open:
            NotchShape(
                topCornerRadius: Self.openedTopCornerRadius,
                bottomCornerRadius: Self.openedBottomCornerRadius,
            )
        }
    }

    // MARK: - Header pill

    private var notchPanel: some View {
        HStack(spacing: Self.interModuleSpacing) {
            self.codexMark
                .frame(width: Self.iconStripWidth, height: self.closedHeight)
            Spacer(minLength: 0)
                .frame(width: self.viewModel.geometry.deviceNotchRect.width)
            self.neutralSymbol
                .frame(width: Self.iconStripWidth, height: self.closedHeight)
        }
        .padding(.horizontal, Self.edgeInset)
        .frame(height: self.closedHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.25)) {
                if self.viewModel.status == .closed {
                    self.viewModel.notchOpen()
                } else {
                    self.viewModel.notchClose()
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(self.panelAccessibilityLabel)
        .accessibilityHint(self.panelAccessibilityHint)
        .accessibilityAddTraits(.isButton)
    }

    private var panelAccessibilityLabel: String {
        self.viewModel.status == .closed ? NotchStrings.collapsedAccessibility : NotchStrings.appName
    }

    private var panelAccessibilityHint: String {
        self.viewModel.status == .open ? NotchStrings.closeHint : ""
    }

    private var codexMark: some View {
        Image(.codexMark)
            .resizable()
            .renderingMode(.template)
            .foregroundColor(.white)
            .frame(width: 16, height: 16)
            .accessibilityHidden(true)
    }

    private var neutralSymbol: some View {
        Image(systemName: "eye.slash")
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.6))
            .accessibilityHidden(true)
    }

    // MARK: - Companion route

    private var companionContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NotchStrings.desktopSource)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))

            HStack(alignment: .center, spacing: 8) {
                Text(NotchStrings.desktopSource)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                self.capabilityBadge(
                    label: NotchStrings.currentlyUnobservable,
                    systemImage: "eye.slash",
                    color: Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255),
                )
                Spacer(minLength: 0)
            }

            Text(NotchStrings.desktopBody)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }

    private func capabilityBadge(label: String, systemImage: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 12))
                .accessibilityHidden(true)
            Text(label)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.06))
        .clipShape(Capsule())
    }
}
