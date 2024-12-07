import SwiftUI

struct DNSRecordListView: View {
    let domain: Domain
    @StateObject private var viewModel = DNSRecordListViewModel()
    @State private var showAddRecord = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text("\(domain.name) Records")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showAddRecord.toggle() }) {
                    Label("Add Record", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Records List
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.records) { record in
                        DNSRecordRow(record: record) {
                            viewModel.editRecord(record)
                        }
                    }
                    .onDelete { indexSet in
                        Task {
                            await viewModel.deleteRecords(at: indexSet)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddRecord) {
            AddDNSRecordView(domain: domain)
        }
        .onAppear {
            Task {
                await viewModel.loadRecords(for: domain)
            }
        }
    }
}

struct DNSRecordRow: View {
    let record: DNSRecord
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.name)
                    .fontWeight(.medium)
                Text(record.type.rawValue)
                    .font(.caption)
                    .padding(4)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Spacer()
            
            Text(record.content)
                .foregroundColor(.secondary)
            
            Button("Edit") {
                onEdit()
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 4)
    }
}