import Foundation

struct Provider: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var type: ProviderType
    var isConnected: Bool
    var email: String?
    var credentials: ProviderCredentials?
    
    init(id: UUID = UUID(), name: String, type: ProviderType, isConnected: Bool = false, email: String? = nil, credentials: ProviderCredentials? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.isConnected = isConnected
        self.email = email
        self.credentials = credentials
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Provider, rhs: Provider) -> Bool {
        lhs.id == rhs.id
    }
}

enum ProviderType: String, Codable, CaseIterable {
    case cloudflare = "Cloudflare"
    case nameDotCom = "Name.com"
    case godaddy = "GoDaddy"
    case route53 = "AWS Route53"
}

enum ProviderCredentials: Codable {
    case cloudflare(CloudflareCredentials)
    
    private enum CodingKeys: String, CodingKey {
        case type, credentials
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .cloudflare(let credentials):
            try container.encode("cloudflare", forKey: .type)
            try container.encode(credentials, forKey: .credentials)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "cloudflare":
            let credentials = try container.decode(CloudflareCredentials.self, forKey: .credentials)
            self = .cloudflare(credentials)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown provider type")
        }
    }
}

// Preview Extension
extension Provider {
    static var preview: Provider {
        Provider(
            name: "Cloudflare",
            type: .cloudflare,
            isConnected: true,
            email: "test@example.com"
        )
    }
}
