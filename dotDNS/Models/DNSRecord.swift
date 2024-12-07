import Foundation

enum RecordType: String, CaseIterable {
    case a = "A"
    case aaaa = "AAAA"
    case cname = "CNAME"
    case mx = "MX"
    case txt = "TXT"
    case srv = "SRV"
}

struct DNSRecord: Identifiable {
    let id: UUID = UUID()
    var type: RecordType
    var name: String
    var content: String
    var ttl: Int
    var priority: Int?
    var provider: Provider
    
    init(type: RecordType, name: String, content: String, ttl: Int, priority: Int? = nil, provider: Provider) {
        self.type = type
        self.name = name
        self.content = content
        self.ttl = ttl
        self.priority = priority
        self.provider = provider
    }
}

// Preview helper
extension DNSRecord {
    static var preview: DNSRecord {
        DNSRecord(
            type: .a,
            name: "example.com",
            content: "192.168.1.1",
            ttl: 3600,
            provider: Provider.preview
        )
    }
}
