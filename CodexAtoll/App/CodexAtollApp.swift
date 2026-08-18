//
//  CodexAtollApp.swift
//  CodexAtoll
//
//  Native application entry for the Codex Atoll notch and menu-bar companion.
//
//  Phase 1 bootstrap: exposes only an empty Settings scene so no ordinary
//  SwiftUI app window is created. Plan 02 adds @NSApplicationDelegateAdaptor
//  together with AppDelegate and the accessory NSPanel lifecycle.
//

import SwiftUI

@main
struct CodexAtollApp: App {
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
