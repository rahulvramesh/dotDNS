import Foundation
import Network

enum NetworkError: LocalizedError {
    case noInternetConnection
    case dnsResolutionFailed
    case invalidURL
    case serverError(Int)
    case decodingError(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .dnsResolutionFailed:
            return "Unable to connect to server. Please check your internet connection."
        case .invalidURL:
            return "Invalid URL configuration."
        case .serverError(let code):
            return "Server error occurred (Code: \(code))"
        case .decodingError(let message):
            return "Data format error: \(message)"
        case .unknown(let error):
            return "An error occurred: \(error.localizedDescription)"
        }
    }
}

@MainActor
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    @Published var isConnected = false
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    func checkConnection() async throws {
        guard isConnected else {
            throw NetworkError.noInternetConnection
        }
    }
    
    func request<T: Decodable>(
        _ url: URL,
        method: String = "GET",
        headers: [String: String] = [:],
        body: Data? = nil
    ) async throws -> T {
        try await checkConnection()
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        request.timeoutInterval = 30
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "Invalid Response", code: -1))
            }
            
            // Print response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response data: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    return try decoder.decode(T.self, from: data)
                } catch let decodingError as DecodingError {
                    let errorDescription = self.describingDecodingError(decodingError)
                    throw NetworkError.decodingError(errorDescription)
                }
            case 401, 403:
                throw NetworkError.serverError(httpResponse.statusCode)
            case 404:
                throw NetworkError.dnsResolutionFailed
            default:
                throw NetworkError.serverError(httpResponse.statusCode)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    private func describingDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .dataCorrupted(let context):
            return "Data corrupted: \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            return "Key '\(key.stringValue)' not found: \(context.debugDescription)"
        case .typeMismatch(let type, let context):
            return "Type '\(type)' mismatch: \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            return "Value of type '\(type)' not found: \(context.debugDescription)"
        @unknown default:
            return "Unknown decoding error: \(error.localizedDescription)"
        }
    }
}
