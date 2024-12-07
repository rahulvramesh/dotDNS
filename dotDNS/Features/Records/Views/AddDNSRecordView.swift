import SwiftUI

struct AddDNSRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddDNSRecordViewModel()
    let domain: Domain
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add DNS Record")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Form
            Form {
                Section("Record Details") {
                    Picker("Record Type", selection: $viewModel.recordType) {
                        ForEach(RecordType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Name", text: $viewModel.name)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Content", text: $viewModel.content)
                        .textFieldStyle(.roundedBorder)
                    
                    if viewModel.recordType == .mx || viewModel.recordType == .srv {
                        Stepper("Priority: \(viewModel.priority)", value: $viewModel.priority, in: 0...65535)
                    }
                    
                    Stepper("TTL: \(viewModel.ttl) seconds", value: $viewModel.ttl, in: 60...86400, step: 60)
                }
            }
            .padding()
            .disabled(viewModel.isLoading)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            // Footer
            HStack {
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .padding(.trailing)
                }
                
                Button("Add Record") {
                    Task {
                        await viewModel.addRecord(to: domain)
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isValid || viewModel.isLoading)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 400)
    }
}

// Preview Provider
struct AddDNSRecordView_Previews: PreviewProvider {
    static var previews: some View {
        AddDNSRecordView(domain: Domain.preview)
    }
}
