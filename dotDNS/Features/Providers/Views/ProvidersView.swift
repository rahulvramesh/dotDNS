import SwiftUI

struct ProvidersView: View {
    @StateObject private var viewModel = ProvidersViewModel()
    @State private var showAddProvider = false
    @State private var selectedProvider: Provider?
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text("DNS Providers")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showAddProvider.toggle() }) {
                    Label("Add Provider", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            if viewModel.errorMessage != nil {
                ErrorBanner(message: viewModel.errorMessage!)
            }
            
            // Providers List
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.providers.isEmpty {
                EmptyStateView()
            } else {
                List(viewModel.providers) { provider in
                    ProviderRowView(provider: provider) {
                        selectedProvider = provider
                        showDeleteAlert = true
                    }
                }
            }
        }
        .sheet(isPresented: $showAddProvider) {
            AddProviderView(providersViewModel: viewModel)
        }
        .alert("Remove Provider?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                if let provider = selectedProvider {
                    viewModel.removeProvider(provider)
                }
            }
        } message: {
            if let provider = selectedProvider {
                Text("Are you sure you want to remove \(provider.name)? This will not affect your DNS records but you will need to add the provider again to manage them.")
            }
        }
        .onAppear {
            viewModel.loadProviders()
        }
    }
}

struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
            Text(message)
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .foregroundColor(.red)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "server.rack")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No DNS Providers")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Add your first DNS provider to start managing your domains")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct ProviderRowView: View {
    let provider: Provider
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(provider.name)
                    .font(.headline)
                Text(provider.type.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status Indicator
            HStack {
                Circle()
                    .fill(provider.isConnected ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(provider.isConnected ? "Connected" : "Disconnected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(12)
            
            Menu {
                Button("View Domains", action: {})
                Button("Edit", action: {})
                Divider()
                Button("Remove", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
