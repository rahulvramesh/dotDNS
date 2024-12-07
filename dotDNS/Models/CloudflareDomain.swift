import Foundation

struct CloudflareDomain: Codable, Identifiable {
    let id: String
    let name: String
    var status: String
    var nameServers: [String]?  // Made optional since it might not always be present
    var originalNameServers: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case nameServers = "name_servers"
        case originalNameServers = "original_name_servers"
    }
}

// Add debug printing to help diagnose API responses
struct CloudflareDomainsResponse: Codable {
    let result: [CloudflareDomain]
    let success: Bool
    let errors: [CloudflareAPIError]
    let messages: [String]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errors = try container.decode([CloudflareAPIError].self, forKey: .errors)
        messages = try container.decode([String].self, forKey: .messages)
        
        do {
            result = try container.decode([CloudflareDomain].self, forKey: .result)
        } catch {
            print("Debug - Error decoding domains: \(error)")
            // If we can, let's print the raw data to see what we're getting
            if let debugContainer = try? decoder.singleValueContainer(),
               let rawString = try? debugContainer.decode(String.self) {
                print("Debug - Raw response: \(rawString)")
            }
            throw error
        }
    }
}
