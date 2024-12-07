import SwiftUI

@MainActor
class AddDNSRecordViewModel: ObservableObject {
    @Published var recordType: RecordType = .a
    @Published var name: String = ""
    @Published var content: String = ""
    @Published var ttl: Int = 3600
    @Published var priority: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var isValid: Bool {
        !name.isEmpty && !content.isEmpty && ttl >= 60
    }
    
    func addRecord(to domain: Domain) async {
        guard isValid else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let record = DNSRecord(
                type: recordType,
                name: name,
                content: content,
                ttl: ttl,
                priority: recordType == .mx || recordType == .srv ? priority : nil,
                provider: domain.provider
            )
            
            // TODO: Implement the actual API call based on provider type
            try await addRecordToProvider(record, domain: domain)
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func addRecordToProvider(_ record: DNSRecord, domain: Domain) async throws {
        switch domain.provider.type {
        case .cloudflare:
            // TODO: Implement Cloudflare record creation
            break
        case .nameDotCom:
            // TODO: Implement Name.com record creation
            break
        case .godaddy:
            // TODO: Implement GoDaddy record creation
            break
        case .route53:
            // TODO: Implement Route53 record creation
            break
        }
    }
}
