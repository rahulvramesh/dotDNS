import SwiftUI

struct SidebarView: View {
    @State private var selectedItem: SidebarItem? = .dashboard
    @StateObject private var providersViewModel = ProvidersViewModel()
    
    enum SidebarItem: Hashable {
        case dashboard
        case providers
        case provider(Provider)
        
        var title: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .providers: return "Providers"
            case .provider(let provider): return provider.name
            }
        }
        
        var icon: String {
            switch self {
            case .dashboard: return "gauge"
            case .providers: return "server.rack"
            case .provider: return "network"
            }
        }
    }
    
    var body: some View {
        List(selection: $selectedItem) {
            Section("General") {
                NavigationLink(value: SidebarItem.dashboard) {
                    Label("Dashboard", systemImage: "gauge")
                }
                
                NavigationLink(value: SidebarItem.providers) {
                    Label("Providers", systemImage: "server.rack")
                }
            }
            
            Section("DNS Providers") {
                ForEach(providersViewModel.providers) { provider in
                    NavigationLink(value: SidebarItem.provider(provider)) {
                        Label(provider.name, systemImage: "network")
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200, maxWidth: 300)
        .navigationDestination(for: SidebarItem.self) { item in
            switch item {
            case .dashboard:
                DashboardView()
            case .providers:
                ProvidersView()
            case .provider(let provider):
                DomainListView(provider: provider)
            }
        }
        .onAppear {
            providersViewModel.loadProviders()
        }
    }
}

#Preview {
    NavigationSplitView {
        SidebarView()
    } detail: {
        Text("Select an item")
    }
}
