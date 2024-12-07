import SwiftUI

struct SidebarView: View {
    @State private var selection: String? = "dashboard"
    @State private var providers: [Provider] = []
    
    var body: some View {
        List(selection: $selection) {
            Section("General") {
                NavigationLink(
                    destination: DashboardView(),
                    tag: "dashboard",
                    selection: $selection
                ) {
                    Label("Dashboard", systemImage: "gauge")
                }
                
                NavigationLink(
                    destination: ProvidersView(),
                    tag: "providers",
                    selection: $selection
                ) {
                    Label("Providers", systemImage: "server.rack")
                }
            }
            
            Section("DNS Providers") {
                ForEach(providers) { provider in
                    NavigationLink(
                        destination: Text(provider.name),
                        tag: provider.id.uuidString,
                        selection: $selection
                    ) {
                        Label(provider.name, systemImage: "network")
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200, maxWidth: 300)
    }
}
