import SwiftUI

@MainActor
class DomainListViewModel: ObservableObject {
    @Published var domains: [Domain] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let provider: Provider
    private let cloudflareService: CloudflareService?
    
    init(provider: Provider) {
        self.provider = provider
        if case .cloudflare(let credentials) = provider.credentials {
            self.cloudflareService = CloudflareService(credentials: credentials)
        } else {
            self.cloudflareService = nil
        }
    }
    
    func loadDomains() async {
        guard let service = cloudflareService else {
            errorMessage = "Invalid provider configuration"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let cfDomains = try await service.getDomains()
            domains = cfDomains.map { cfDomain in
                Domain(
                    name: cfDomain.name,
                    provider: self.provider,
                    status: cfDomain.status == "active" ? .active : .inactive,
                    recordCount: 0  // We'll update this when we fetch records
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
