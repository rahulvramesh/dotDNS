import Foundation

enum ProviderError: LocalizedError {
    case unsupportedProvider
    case invalidCredentials
    case apiError(String)
    case networkError(NetworkError)
    
    var errorDescription: String? {
        switch self {
        case .unsupportedProvider:
            return "This DNS provider is not yet supported"
        case .invalidCredentials:
            return "Invalid provider credentials"
        case .apiError(let message):
            return "Provider API Error: \(message)"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}
