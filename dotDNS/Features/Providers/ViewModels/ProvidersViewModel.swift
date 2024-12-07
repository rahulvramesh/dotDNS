import SwiftUI

@MainActor
class ProvidersViewModel: ObservableObject {
    @Published var providers: [Provider] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadProviders() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                providers = try await ProviderStorage.shared.loadProviders()
            } catch {
                errorMessage = "Failed to load providers: \(error.localizedDescription)"
            }
        }
    }
    
    func addProvider(_ provider: Provider) {
        Task {
            do {
                try await ProviderStorage.shared.addProvider(provider)
                await loadProviders()
            } catch {
                errorMessage = "Failed to add provider: \(error.localizedDescription)"
            }
        }
    }
    
    func removeProvider(_ provider: Provider) {
        Task {
            do {
                try await ProviderStorage.shared.removeProvider(provider)
                await loadProviders()
            } catch {
                errorMessage = "Failed to remove provider: \(error.localizedDescription)"
            }
        }
    }
    
    func updateProvider(_ provider: Provider) {
        Task {
            do {
                try await ProviderStorage.shared.updateProvider(provider)
                await loadProviders()
            } catch {
                errorMessage = "Failed to update provider: \(error.localizedDescription)"
            }
        }
    }
}
