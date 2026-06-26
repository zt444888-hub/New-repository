import SwiftUI

struct RecentRow: View {
    let item: ConversionItem
    let action: () -> Void
    
    init(item: ConversionItem, action: @escaping () -> Void) {
        self.item = item
        self.action = action
    }
    
    var icon: String {
        switch item.fromFormat.lowercased() {
        case "mov", "mp4": return "film"
        case "m4a", "mp3", "wav": return "music.note"
        default: return "doc"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.bgElevated)
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundColor(.accent)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.fileName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.textPrimary)
                    Text("\(item.fromFormat) → \(item.toFormat) · \(item.originalSize)")
                        .font(.system(size: 12))
                        .foregroundColor(.textTertiary)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color.bgCard)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}