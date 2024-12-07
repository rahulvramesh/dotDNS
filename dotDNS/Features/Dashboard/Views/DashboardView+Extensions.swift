// DashboardView+Extensions.swift
import SwiftUI


extension DashboardView {
    var domainsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Domains")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .top])
            
            if viewModel.domains.isEmpty {
                Text("No domains found")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            } else {
                ForEach(viewModel.domains) { domain in
                    DomainRowView(domain: domain) {
                        viewModel.manageDomain(domain)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .top])
            
            if viewModel.recentActivities.isEmpty {
                Text("No recent activity")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            } else {
                ForEach(viewModel.recentActivities) { activity in
                    ActivityRowView(activity: activity)
                        .padding(.horizontal)
                }
            }
        }
    }
}

// Supporting Views
struct DomainRowView: View {
    let domain: Domain
    let onManage: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(domain.name)
                    .fontWeight(.medium)
                Text(domain.provider.name)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Spacer()
            
            StatusBadgeView(status: domain.status)
                .padding(.trailing, 8)
            
            Button("Manage", action: onManage)
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ActivityRowView: View {
    let activity: DashboardViewModel.ActivityItem
    
    var body: some View {
        HStack {
            Image(systemName: activity.icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .fontWeight(.medium)
                Text(activity.timestamp.formatted())
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Spacer()
            
            Text(activity.domain)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
