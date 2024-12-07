import Foundation

// MARK: - Credentials
struct CloudflareCredentials: Codable {
    let token: String?
    let email: String?
    let globalApiKey: String?
    
    init(token: String? = nil, email: String? = nil, globalApiKey: String? = nil) {
        self.token = token
        self.email = email
        self.globalApiKey = globalApiKey
    }
    
    static func withToken(_ token: String) -> CloudflareCredentials {
        CloudflareCredentials(token: token)
    }
    
    static func withGlobalKey(email: String, key: String) -> CloudflareCredentials {
        CloudflareCredentials(email: email, globalApiKey: key)
    }
}

// MARK: - API Response Models
struct CloudflareResponse<T: Codable>: Codable {
    let success: Bool
    let errors: [CloudflareAPIError]
    let messages: [String]
    let result: T?
}

struct CloudflareAPIError: Codable {
    let code: Int
    let message: String
}

struct CloudflareTokenStatus: Codable {
    let id: String
    let status: String
    let type: String?
}

struct CloudflareUserDetails: Codable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "first_name"
        case lastName = "last_name"
    }
    
    var fullName: String {
        [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
}

// MARK: - Error Types
enum CloudflareServiceError: LocalizedError {
    case invalidCredentials
    case apiError(String)
    case rateLimitExceeded
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid API credentials. Please check your API token or key."
        case .apiError(let message):
            return "Cloudflare API Error: \(message)"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .networkError(let message):
            return "Network Error: \(message)"
        }
    }
}
