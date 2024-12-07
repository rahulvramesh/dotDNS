import SwiftUI

struct AddProviderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddProviderViewModel
    
    init(providersViewModel: ProvidersViewModel) {
        _viewModel = StateObject(wrappedValue: AddProviderViewModel(providersViewModel: providersViewModel))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add DNS Provider")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Form
            Form {
                providerSection
                
                if viewModel.selectedProviderType == .cloudflare {
                    cloudflareSection
                }
                
                optionsSection
                
                if viewModel.isAuthenticated {
                    successSection
                }
            }
            .padding()
            .disabled(viewModel.isLoading)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            // Footer
            HStack {
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .padding(.trailing)
                }
                
                Button("Add Provider") {
                    Task {
                        await viewModel.addProvider()
                        if viewModel.isAuthenticated {
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isValid || viewModel.isLoading)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 400)
    }
    
    private var providerSection: some View {
        Section("Provider") {
            Picker("Provider Type", selection: $viewModel.selectedProviderType) {
                ForEach(ProviderType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
        }
    }
    
    private var cloudflareSection: some View {
        Section("Authentication") {
            Picker("Authentication Method", selection: $viewModel.useApiToken) {
                Text("API Token").tag(true)
                Text("Global API Key").tag(false)
            }
            .pickerStyle(.segmented)
            
            if viewModel.useApiToken {
                SecureField("API Token", text: $viewModel.apiToken)
                Text("API Tokens are the recommended way to authenticate with Cloudflare API")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                TextField("Email", text: $viewModel.email)
                SecureField("Global API Key", text: $viewModel.globalApiKey)
                Text("Global API Keys have full account access. API Tokens are recommended instead.")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
    
    private var optionsSection: some View {
        Section("Options") {
            Toggle("Save credentials securely", isOn: $viewModel.saveCredentials)
            Toggle("Verify connection", isOn: $viewModel.verifyConnection)
        }
    }
    
    private var successSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Label("Successfully connected", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                if let name = viewModel.userName {
                    Text("Name: \(name)")
                        .font(.caption)
                }
                
                if let email = viewModel.userEmail {
                    Text("Email: \(email)")
                        .font(.caption)
                }
            }
        }
    }
}
