import SwiftUI

struct SizeCompareCard: View {
    let before: String
    let after: String
    let saved: String
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 2) {
                Text("Before")
                    .font(.system(size: 12))
                    .foregroundColor(.textTertiary)
                Text(before)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            
            Image(systemName: "arrow.right")
                .foregroundColor(.green)
                .font(.system(size: 22, weight: .bold))
            
            VStack(spacing: 2) {
                Text("After")
                    .font(.system(size: 12))
                    .foregroundColor(.textTertiary)
                Text(after)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Text(saved)
                    .font(.system(size: 13))
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
}