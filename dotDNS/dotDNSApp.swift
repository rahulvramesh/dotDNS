// dotDNSApp.swift
import SwiftUI

@main
struct dotDNSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(
                    minWidth: Constants.UI.minWindowWidth,
                    minHeight: Constants.UI.minWindowHeight
                )
        }
        //.windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
    }
}


#Preview {
    ContentView()
}
