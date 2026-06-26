import SwiftUI

struct ResolutionChip: View {
    let label: String
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.textPrimary)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(selected ? Color.accent.opacity(0.12) : Color.bgCard)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selected ? Color.accent : .clear, lineWidth: 2)
                )
                .scaleEffect(selected ? 1.02 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: selected)
        }
        .buttonStyle(.plain)
    }
}