import Foundation

actor ProviderStorage {
    static let shared = ProviderStorage()
    private let defaults = UserDefaults.standard
    private let providersKey = "stored_providers"
    
    private init() {}
    
    func saveProviders(_ providers: [Provider]) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(providers)
        defaults.set(data, forKey: providersKey)
    }
    
    func loadProviders() async throws -> [Provider] {
        guard let data = defaults.data(forKey: providersKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([Provider].self, from: data)
    }
    
    func addProvider(_ provider: Provider) async throws {
        var providers = try await loadProviders()
        providers.append(provider)
        try await saveProviders(providers)
    }
    
    func updateProvider(_ provider: Provider) async throws {
        var providers = try await loadProviders()
        if let index = providers.firstIndex(where: { $0.id == provider.id }) {
            providers[index] = provider
            try await saveProviders(providers)
        }
    }
    
    func removeProvider(_ provider: Provider) async throws {
        var providers = try await loadProviders()
        providers.removeAll { $0.id == provider.id }
        try await saveProviders(providers)
    }
}
