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

import AppKit
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
    static let openChatGPT = String(localized: "Open ChatGPT")
    static let openingChatGPT = String(localized: "Opening ChatGPT…")
    static let desktopHandoffError = String(localized: "ChatGPT could not be opened. Open it from Applications, then try again.")
    static let closeHint = String(localized: "Click to close")
    static let usageUnavailable = String(localized: "Usage unavailable")
    static let usageDetailHeading = String(localized: "Usage details unavailable here")
    static let usageDetailBody = String(localized: "Codex Atoll does not read account credentials or estimate your quota. View current limits on the official Codex page.")
    static let usageCTA = String(localized: "Open official Codex usage")
    static let usageOpening = String(localized: "Opening official Codex usage…")
    static let usageHandoffError = String(localized: "The official Codex usage page could not be opened. Check your default browser, then try again.")
    static let back = String(localized: "Back")
    static let openMenu = String(localized: "Open Codex Atoll menu")
    static let quit = String(localized: "Quit Codex Atoll")
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
                self.routeContent
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
        Group {
            if self.viewModel.status == .closed {
                self.closedPill
            } else {
                self.expandedHeader
            }
        }
        .padding(.horizontal, Self.edgeInset)
        .frame(height: self.closedHeight)
    }

    private var closedPill: some View {
        HStack(spacing: Self.interModuleSpacing) {
            self.codexMark
                .frame(width: Self.iconStripWidth, height: self.closedHeight)
            Spacer(minLength: 0)
                .frame(width: self.viewModel.geometry.deviceNotchRect.width)
            self.neutralSymbol
                .frame(width: Self.iconStripWidth, height: self.closedHeight)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.25)) {
                self.viewModel.notchOpen()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(NotchStrings.collapsedAccessibility)
        .accessibilityAddTraits(.isButton)
    }

    /// The expanded header: usage affordance top-left, menu affordance
    /// top-right. Tapping the header background closes the notch; the
    /// contained buttons consume their own taps.
    private var expandedHeader: some View {
        HStack(spacing: Self.interModuleSpacing) {
            self.usageAffordance
            Spacer(minLength: 0)
            self.menuButton
        }
        .frame(height: self.closedHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.25)) {
                self.viewModel.notchClose()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityHint(NotchStrings.closeHint)
    }

    /// Top-left `Usage unavailable` affordance. A button that navigates to the
    /// in-notch usage detail — never a percentage, reset time, or loading state.
    private var usageAffordance: some View {
        Button {
            self.viewModel.openUsageUnavailable()
        } label: {
            HStack(spacing: 4) {
                Text(NotchStrings.usageUnavailable)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
                    .accessibilityHidden(true)
            }
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// Top-right icon-only menu control. Announceable as `Open Codex Atoll
    /// menu` with a 44x44 hit target; toggles the local menu route.
    private var menuButton: some View {
        Button {
            self.toggleMenu()
        } label: {
            Image(systemName: self.viewModel.destination == .menu ? "xmark" : "line.3.horizontal")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(NotchStrings.openMenu)
    }

    private func toggleMenu() {
        if self.viewModel.destination == .menu {
            self.viewModel.goBack()
        } else {
            self.viewModel.openMenu()
        }
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

    // MARK: - Routes

    @ViewBuilder
    private var routeContent: some View {
        switch self.viewModel.destination {
        case .companion:
            ScrollView(.vertical, showsIndicators: true) {
                DesktopCompanionView()
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
            }
        case .usageUnavailable:
            UsageUnavailableView(onBack: { self.viewModel.goBack() })
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        case .menu:
            NotchMenuView(
                onBack: { self.viewModel.goBack() },
                onQuit: { NSApplication.shared.terminate(nil) },
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }
}
