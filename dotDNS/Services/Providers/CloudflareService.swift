import Foundation

class CloudflareService {
    private let baseURL = "https://api.cloudflare.com/client/v4"
    private var credentials: CloudflareCredentials
    private let networkManager: NetworkManager
    
    init(credentials: CloudflareCredentials, networkManager: NetworkManager = .shared) {
        self.credentials = credentials
        self.networkManager = networkManager
    }
    
    private func makeRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var headers = [
            "Content-Type": "application/json"
        ]
        
        if let token = credentials.token {
            headers["Authorization"] = "Bearer \(token)"
        } else if let email = credentials.email, let apiKey = credentials.globalApiKey {
            headers["X-Auth-Email"] = email
            headers["X-Auth-Key"] = apiKey
        } else {
            throw CloudflareServiceError.invalidCredentials
        }
        
        let data = try await networkManager.request(
            url,
            method: method,
            headers: headers,
            body: body
        )
        
        // Add debug printing of raw response
        if let responseString = String(data: data, encoding: .utf8) {
            print("Debug - Raw API response: \(responseString)")
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Debug - Decoding error: \(error)")
            throw error
        }
    }

    func getDomains() async throws -> [CloudflareDomain] {
        let endpoint = "/zones"
        
        // Add debug print for the request
        print("Debug - Requesting domains from Cloudflare...")
        
        let response: CloudflareDomainsResponse = try await makeRequest(endpoint: endpoint)
        
        // Add debug print for the response
        print("Debug - Got response with success: \(response.success)")
        if !response.success {
            print("Debug - Errors: \(response.errors)")
        }
        
        guard response.success else {
            throw CloudflareServiceError.apiError(response.errors.first?.message ?? "Unknown error")
        }
        
        return response.result
    }
    
    func verifyCredentials() async throws {
        if let token = credentials.token {
            let endpoint = "/user/tokens/verify"
            let response: TokenVerifyResponse = try await makeRequest(endpoint: endpoint)
            
            guard response.success,
                  let status = response.result.status,
                  status == "active" else {
                throw CloudflareServiceError.invalidCredentials
            }
        } else {
            // Verify Global API Key by fetching user details
            try await getUserDetails()
        }
    }
    
    func getUserDetails() async throws -> UserDetailsResponse.UserDetails {
        let endpoint = "/user"
        let response: UserDetailsResponse = try await makeRequest(endpoint: endpoint)
        
        guard response.success,
              let userDetails = response.result else {
            throw CloudflareServiceError.apiError("Failed to get user details")
        }
        
        return userDetails
    }
}

// MARK: - Response Types
extension CloudflareService {
    struct TokenVerifyResponse: Codable {
        let success: Bool
        let errors: [APIError]
        let messages: [Message]
        let result: TokenStatus
        
        struct TokenStatus: Codable {
            let id: String
            let status: String?
            let type: String?
        }
        
        struct APIError: Codable {
            let code: Int
            let message: String
        }
        
        struct Message: Codable {
            let code: Int?
            let message: String
        }
    }
    
    struct UserDetailsResponse: Codable {
        let success: Bool
        let errors: [APIError]
        let messages: [String]
        let result: UserDetails?
        
        struct UserDetails: Codable {
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
        
        struct APIError: Codable {
            let code: Int
            let message: String
        }
    }
}
