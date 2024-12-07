import Foundation

enum Constants {
    enum API {
        static let baseURL = "https://api.example.com"
        static let version = "v1"
    }
    
    enum UI {
        static let minWindowWidth: CGFloat = 800
        static let minWindowHeight: CGFloat = 500  // Reduced from 600
        static let sidebarWidth: CGFloat = 200
        static let toolbarHeight: CGFloat = 38    // Added constant for toolbar height
    }
}
