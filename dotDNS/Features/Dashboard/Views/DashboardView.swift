// DashboardView.swift
import SwiftUI

struct DashboardView: View {
    // Change access level from private to internal
    @StateObject var viewModel = DashboardViewModel()
    @StateObject var providersViewModel = ProvidersViewModel()
    @State private var showAddProvider = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            toolbar
                .background(Color(NSColor.windowBackgroundColor))
            
            // Main Content
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        statsCard(title: "Total Domains", value: "\(viewModel.totalDomains)", icon: "globe")
                        statsCard(title: "Active Records", value: "\(viewModel.totalRecords)", icon: "server.rack")
                        statsCard(title: "DNS Providers", value: "\(viewModel.totalProviders)", icon: "network")
                        statsCard(title: "Domains Expiring Soon", value: "\(viewModel.expiringDomains)", icon: "exclamationmark.triangle")
                    }
                    .padding(.horizontal)
                    
                    // Recent Activity
                    recentActivitySection
                    
                    // Domains List
                    domainsList
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showAddProvider) {
            AddProviderView(providersViewModel: providersViewModel)
        }
        .onAppear {
            viewModel.loadData()
            providersViewModel.loadProviders()
        }
    }
    
    // Make toolbar internal instead of private
    var toolbar: some View {
        HStack {
            Text("Dashboard")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: { showAddProvider.toggle() }) {
                Label("Add Provider", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            
            Button(action: {
                viewModel.refresh()
                providersViewModel.loadProviders()
            }) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // Make statsCard internal instead of private
    func statsCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                
                Text(title)
                    .font(.headline)
            }
            
            Text(value)
                .font(.system(size: 34, weight: .bold))
            
            if let trend = viewModel.getTrend(for: title) {
                HStack(spacing: 4) {
                    Image(systemName: trend.isPositive ? "arrow.up" : "arrow.down")
                    Text("\(trend.value)%")
                    Text("vs last month")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
                .foregroundStyle(trend.isPositive ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
