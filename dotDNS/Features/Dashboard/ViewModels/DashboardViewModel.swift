// Features/Dashboard/ViewModels/DashboardViewModel.swift
import Foundation

class DashboardViewModel: ObservableObject {
    @Published var totalDomains = 0
    @Published var totalRecords = 0
    @Published var totalProviders = 0
    @Published var expiringDomains = 0
    @Published var recentActivities: [ActivityItem] = []
    @Published var domains: [Domain] = []
    @Published var isLoading = false
    
    struct ActivityItem: Identifiable {
        let id = UUID()
        let title: String
        let timestamp: Date
        let domain: String
        let icon: String
    }
    
    struct Trend {
        let value: Int
        let isPositive: Bool
    }
    
    func loadData() {
        isLoading = true
        // Add network call here
        isLoading = false
    }
    
    func refresh() {
        loadData()
    }
    
    func getTrend(for metric: String) -> Trend? {
        // Implement trend calculation
        return nil
    }
    
    func manageDomain(_ domain: Domain) {
        // Implement domain management
    }
}
