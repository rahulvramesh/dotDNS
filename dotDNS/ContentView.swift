import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            DashboardView()
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: Constants.UI.minWindowWidth,
               minHeight: 500)
    }
}

#Preview {
    ContentView()
}
