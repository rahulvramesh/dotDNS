import SwiftUI

struct StatusBadgeView: View {
    let status: DomainStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .clipShape(Capsule())
    }
    
    private var backgroundColor: Color {
        switch status {
        case .active:
            return .green
        case .inactive:
            return .red
        case .transferring:
            return .orange
        }
    }
}

#Preview {
    HStack {
        StatusBadgeView(status: .active)
        StatusBadgeView(status: .inactive)
        StatusBadgeView(status: .transferring)
    }
    .padding()
}