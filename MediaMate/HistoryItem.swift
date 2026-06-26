import SwiftUI

struct HistoryListItem: View {
    let item: ConversionItem
    
    var icon: String {
        switch item.fromFormat.lowercased() {
        case "mov", "mp4": return "film"
        case "m4a", "mp3", "wav": return "music.note"
        default: return "doc"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.bgElevated)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(.textSecondary)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.fileName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textPrimary)
                
                if let convertedSize = item.convertedSize {
                    Text("\(item.fromFormat) → \(item.toFormat) · \(item.originalSize) → \(convertedSize)")
                        .font(.system(size: 12))
                        .foregroundColor(.textTertiary)
                } else {
                    Text("\(item.fromFormat) → \(item.toFormat) · \(item.originalSize)")
                        .font(.system(size: 12))
                        .foregroundColor(.textTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(item.status == .completed ? "Done" : "Failed")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(item.status == .completed ? .green : .red)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}