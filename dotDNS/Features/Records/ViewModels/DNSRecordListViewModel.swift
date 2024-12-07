import Foundation
import Combine

@MainActor
class DNSRecordListViewModel: ObservableObject {
    @Published var records: [DNSRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadRecords(for domain: Domain) async {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Implement API call to load records
        // This should use the appropriate provider service based on domain.provider.type
    }
    
    func editRecord(_ record: DNSRecord) {
        // TODO: Show edit record sheet
    }
    
    func deleteRecords(at indexSet: IndexSet) async {
        guard let provider = records.first?.provider else { return }
        
        do {
            for index in indexSet {
                let record = records[index]
                try await deleteRecord(record, using: provider)
                records.remove(at: index)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func deleteRecord(_ record: DNSRecord, using provider: Provider) async throws {
        // TODO: Implement API call to delete record
        // This should use the appropriate provider service based on provider.type
    }
}