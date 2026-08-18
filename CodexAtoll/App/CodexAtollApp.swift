//
//  CodexAtollApp.swift
//  CodexAtoll
//
//  Native application entry for the Codex Atoll notch and menu-bar companion.
//
//  The app is a window-only accessory shell: the @main entry attaches
//  AppDelegate, which owns the native notch panel. No ordinary SwiftUI
//  window is created; the Settings scene stays empty.
//

import SwiftUI

@main
struct CodexAtollApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
