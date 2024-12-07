import SwiftUI

@MainActor
class AddProviderViewModel: ObservableObject {
    @Published var selectedProviderType: ProviderType = .cloudflare
    @Published var apiToken = ""
    @Published var email = ""
    @Published var globalApiKey = ""
    @Published var useApiToken = true
    @Published var saveCredentials = true
    @Published var verifyConnection = true
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var userName: String?
    @Published var userEmail: String?
    
    private var networkManager: NetworkManager
    private var providersViewModel: ProvidersViewModel
    
    init(networkManager: NetworkManager = .shared, providersViewModel: ProvidersViewModel) {
        self.networkManager = networkManager
        self.providersViewModel = providersViewModel
    }
    
    var isValid: Bool {
        switch selectedProviderType {
        case .cloudflare:
            if useApiToken {
                return !apiToken.isEmpty
            } else {
                return !email.isEmpty && !globalApiKey.isEmpty
            }
        default:
            return false
        }
    }
    
    func addProvider() async {
        guard isValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            switch selectedProviderType {
            case .cloudflare:
                try await addCloudflareProvider()
            default:
                throw ProviderError.unsupportedProvider
            }
            
            if saveCredentials {
                try await saveToKeychain()
            }
            
            isAuthenticated = true
            
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        } catch let error as CloudflareServiceError {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    private func addCloudflareProvider() async throws {
        let credentials: CloudflareCredentials
        
        if useApiToken {
            credentials = .withToken(apiToken)
        } else {
            credentials = .withGlobalKey(email: email, key: globalApiKey)
        }
        
        let service = CloudflareService(credentials: credentials, networkManager: networkManager)
        
        if verifyConnection {
            try await service.verifyCredentials()
            let userDetails = try await service.getUserDetails()
            
            userName = userDetails.fullName
            userEmail = userDetails.email
            
            // Create and store the provider
            let provider = Provider(
                name: userDetails.email,
                type: .cloudflare,
                isConnected: true,
                email: userDetails.email,
                credentials: .cloudflare(credentials)
            )
            
            providersViewModel.addProvider(provider)
        }
    }
    
    private func saveToKeychain() async throws {
        let prefix = "cloudflare"
        
        if useApiToken {
            try await KeychainService.saveCredentials(
                key: "\(prefix)_api_token",
                value: apiToken
            )
        } else {
            try await KeychainService.saveCredentials(
                key: "\(prefix)_email",
                value: email
            )
            try await KeychainService.saveCredentials(
                key: "\(prefix)_global_key",
                value: globalApiKey
            )
        }
    }
}
