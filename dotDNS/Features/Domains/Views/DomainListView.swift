import SwiftUI

struct DomainListView: View {
    let provider: Provider
    @StateObject private var viewModel: DomainListViewModel
    
    init(provider: Provider) {
        self.provider = provider
        self._viewModel = StateObject(wrappedValue: DomainListViewModel(provider: provider))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text("\(provider.name) Domains")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.loadDomains()
                    }
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(error)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.domains.isEmpty {
                VStack {
                    Image(systemName: "globe")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No domains found")
                        .font(.headline)
                    Text("Domains connected to this provider will appear here")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.domains) { domain in
                    NavigationLink(destination: DNSRecordListView(domain: domain)) {
                        DomainRowView(domain: domain) {
                            // Handle domain management action here
                            // For now, we'll use it to navigate to records
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadDomains()
            }
        }
    }
}

#Preview {
    DomainListView(provider: Provider.preview)
}
