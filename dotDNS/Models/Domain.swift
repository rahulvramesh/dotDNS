import Foundation

struct Domain: Identifiable {
    let id: UUID = UUID()
    var name: String
    var provider: Provider
    var status: DomainStatus
    var recordCount: Int
}

enum DomainStatus: String {
    case active = "Active"
    case inactive = "Inactive"
    case transferring = "Transferring"
}

extension Domain {
    static var preview: Domain {
        Domain(name: "example.com", provider: .preview, status: .active, recordCount: 10)
    }
}
